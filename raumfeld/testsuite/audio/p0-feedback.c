/*
 * P0Feedback
 */

#include <string.h>
#include <arpa/inet.h>
#include <errno.h>
#include <glib-object.h>
#include <raumfeld/time.h>

#include "p0-renderer-types.h"
#include "p0-feedback.h"


#define FEEDBACK_SEND_TIMEOUT  100  /*  10 times per second   */


struct _P0Feedback
{
        GObject  parent_instance;

        int      sockfd;

        GList   *clients;

        guint    send_timeout;
        guint    subscription_timeout;

        guint    output_level_l;
        guint    output_level_r;
        guint    input_level_l;
        guint    input_level_r;
};

/*  struct allocated per client  */
typedef struct
{
        gulong  addr;    /*  client host           */
        gushort port;    /*  client port           */
        time_t  timeout; /*  subscription timeout  */
} Client;


static void       p0_feedback_dispose              (GObject      *object);
static void       p0_feedback_finalize             (GObject      *object);

static GList    * p0_feedback_lookup_client        (P0Feedback   *feedback,
                                                    const Client *template);

static gboolean   p0_feedback_send_timeout         (P0Feedback   *feedback);
static gboolean   p0_feedback_subscription_timeout (P0Feedback   *feedback);

static void       p0_feedback_install_timeouts     (P0Feedback   *feedback);


G_DEFINE_TYPE (P0Feedback, p0_feedback, G_TYPE_OBJECT)


static void
p0_feedback_class_init (P0FeedbackClass *klass)
{
        GObjectClass *object_class = G_OBJECT_CLASS (klass);

        object_class->dispose  = p0_feedback_dispose;
        object_class->finalize = p0_feedback_finalize;
}


static void
p0_feedback_init (P0Feedback *feedback)
{
	if ((feedback->sockfd =
             socket (AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
	{
		g_warning ("Can't create socket: %s", g_strerror (errno));
	}
}

static void
p0_feedback_dispose (GObject *object)
{
        P0Feedback *feedback = P0_FEEDBACK (object);

        if (feedback->subscription_timeout) {
                g_source_remove (feedback->subscription_timeout);
                feedback->subscription_timeout = 0;
        }

        if (feedback->send_timeout) {
                g_source_remove (feedback->send_timeout);
                feedback->send_timeout = 0;
        }

        G_OBJECT_CLASS (p0_feedback_parent_class)->dispose (object);
}

static void
p0_feedback_finalize (GObject *object)
{
        P0Feedback *feedback = P0_FEEDBACK (object);
        GList      *iter;

        for (iter = feedback->clients; iter; iter = iter->next)
                g_slice_free (Client, iter->data);

        g_list_free (feedback->clients);
        feedback->clients = NULL;

        G_OBJECT_CLASS (p0_feedback_parent_class)->finalize (object);
}

P0Feedback *
p0_feedback_new (void)
{
        return g_object_new (TYPE_P0_FEEDBACK, NULL);
}

void
p0_feedback_subscribe (P0Feedback  *feedback,
                       const gchar *client_ip,
                       gint         client_port,
                       gint         timeout)
{
        Client  template;
        GList  *link;

        g_return_if_fail (IS_P0_FEEDBACK (feedback));
        g_return_if_fail (client_ip != NULL);
        g_return_if_fail (client_port > 0);
        g_return_if_fail (timeout > 0);

	template.addr = inet_addr (client_ip);
	template.port = htons (client_port);

        link = p0_feedback_lookup_client (feedback, &template);

        if (link)
        {
                Client *client = link->data;
                time_t  now    = time (NULL);

                client->timeout = now + timeout;
        }
        else
        {
                Client *client = g_slice_dup (Client, &template);
                time_t  now    = time (NULL);

                client->timeout = now + timeout;

                feedback->clients = g_list_prepend (feedback->clients,
                                                    client);
        }

        p0_feedback_install_timeouts (feedback);
}

void
p0_feedback_unsubscribe (P0Feedback  *feedback,
                         const gchar *client_ip,
                         gint         client_port)
{
        Client  template;
        GList  *link;

        g_return_if_fail (IS_P0_FEEDBACK (feedback));
        g_return_if_fail (client_ip != NULL);
        g_return_if_fail (client_port > 0);

	template.addr = inet_addr (client_ip);
	template.port = htons (client_port);

        link = p0_feedback_lookup_client (feedback, &template);

        if (link)
        {
                Client *client = link->data;

                feedback->clients = g_list_delete_link (feedback->clients,
                                                        link);
                g_slice_free (Client, client);
        }

        p0_feedback_install_timeouts (feedback);
}

/*  This function is called from the alsa thread. But we don't do any
 *  locking as this is the only place that ever writes to the levels.
 */
void
p0_feedback_set_levels (P0Feedback *feedback,
                        gint16      playback_level_l,
                        gint16      playback_level_r,
                        gint16      capture_level_l,
                        gint16      capture_level_r)
{
        guint output_level_l;
        guint output_level_r;
        guint input_level_l;
        guint input_level_r;

        g_return_if_fail (IS_P0_FEEDBACK (feedback));

        if (! feedback->clients)
                return;

        output_level_l = MAX (feedback->output_level_l, playback_level_l);
        output_level_r = MAX (feedback->output_level_r, playback_level_r);
        input_level_l  = MAX (feedback->input_level_l,  capture_level_l);
        input_level_r  = MAX (feedback->input_level_r,  capture_level_r);

        /*  Set all levels here from local variables to reduce the
         *  chance that the sender thread uses the values while we are
         *  updating them.
         */
        feedback->output_level_l = output_level_l;
        feedback->output_level_r = output_level_r;
        feedback->input_level_l  = input_level_l;
        feedback->input_level_r  = input_level_r;
}

static GList *
p0_feedback_lookup_client (P0Feedback   *feedback,
                           const Client *template)
{
        GList *iter;

        for (iter = feedback->clients; iter; iter = iter->next)
        {
                const Client *client = iter->data;

                if (client->addr == template->addr &&
                    client->port == template->port)
                        return iter;
        }

        return NULL;
}

static gboolean
p0_feedback_send_timeout (P0Feedback *feedback)
{

        OfeedbackPacket	 packet;
        const GList     *iter;

        packet.magic          = g_htonl (OFEEDBACK_MAGIC);
        packet.output_level_l = g_htons (feedback->output_level_l);
        packet.output_level_r = g_htons (feedback->output_level_r);
        packet.input_level_l  = g_htons (feedback->input_level_l);
        packet.input_level_r  = g_htons (feedback->input_level_r);

        feedback->output_level_l = 0;
        feedback->output_level_r = 0;
        feedback->input_level_l  = 0;
        feedback->input_level_r  = 0;

        for (iter = feedback->clients; iter; iter = iter->next)
        {
                const Client       *client = iter->data;
                struct sockaddr_in  addr;

                addr.sin_family      = AF_INET;
                addr.sin_addr.s_addr = client->addr;
                addr.sin_port        = client->port;

                if (sendto (feedback->sockfd,
                            &packet, sizeof (packet),
                            0,
                            (struct sockaddr *) &addr, sizeof(addr)) == -1)
                {
                        /* FIXME: should we remove this client? */
                        g_printerr ("sendto failed: %s\n", g_strerror (errno));
                }
        }

        return TRUE;
}

static gboolean
p0_feedback_subscription_timeout (P0Feedback *feedback)
{
        GList *iter;
        time_t  now;

        now = time (NULL);

        for (iter = feedback->clients; iter; )
        {
                GList  *next   = iter->next;
                Client *client = iter->data;

                if (now >= client->timeout) {
                        feedback->clients =
                                g_list_delete_link (feedback->clients, iter);
                        g_slice_free (Client, client);
                }

                iter = next;
        }

        feedback->subscription_timeout = 0;

        p0_feedback_install_timeouts (feedback);

        return FALSE;
}

static void
p0_feedback_install_timeouts (P0Feedback *feedback)
{
        const GList *iter;
        Client      *client;
        time_t       now;
        time_t       timeout;

        if (feedback->subscription_timeout) {
                g_source_remove (feedback->subscription_timeout);
                feedback->subscription_timeout = 0;
        }

        if (! feedback->clients) {
                if (feedback->send_timeout) {
                        g_source_remove (feedback->send_timeout);
                        feedback->send_timeout = 0;
                }

                feedback->output_level_l = 0;
                feedback->output_level_r = 0;
                feedback->input_level_l  = 0;
                feedback->input_level_r  = 0;

                return;
        }

        client = feedback->clients->data;
        timeout = client->timeout;

        for (iter = feedback->clients->next; iter; iter = iter->next)
        {
                client = iter->data;

                if (client->timeout < timeout)
                        timeout = client->timeout;
        }

        now = time (NULL);

        feedback->subscription_timeout =
                g_timeout_add_seconds (MAX (1, timeout - now),
                                       (GSourceFunc) p0_feedback_subscription_timeout,
                                       feedback);

        if (! feedback->send_timeout) {
                feedback->send_timeout =
                        g_timeout_add (FEEDBACK_SEND_TIMEOUT,
                                       (GSourceFunc) p0_feedback_send_timeout,
                                       feedback);
        }
}
