/*
 * P0Generator:
 *
 * This class implements the RaumfeldGenerator service
 */

#include <string.h>

#include <raumfeld/dlna.h>

#include "p0-renderer-types.h"
#include "p0-feedback.h"
#include "p0-generator.h"


struct _P0Generator
{
        GObject           parent_instance;

        GUPnPServiceInfo *service;
        P0Feedback       *feedback;
};


static void  p0_generator_finalize      (GObject            *object);

static void  p0_generator_subscribe_to_feedback
                                        (GUPnPService       *service,
                                         GUPnPServiceAction *action,
                                         P0Generator        *generator);

static void  p0_generator_unsubscribe_from_feedback
                                        (GUPnPService       *service,
                                         GUPnPServiceAction *action,
                                         P0Generator        *generator);


G_DEFINE_TYPE (P0Generator, p0_generator, G_TYPE_OBJECT)


static void
p0_generator_class_init (P0GeneratorClass *klass)
{
        GObjectClass *object_class = G_OBJECT_CLASS (klass);

        object_class->finalize = p0_generator_finalize;
}


static void
p0_generator_init (P0Generator *generator)
{
}

static void
p0_generator_finalize (GObject *object)
{
        P0Generator *generator = P0_GENERATOR (object);

        g_object_unref (generator->service);
        g_object_unref (generator->feedback);

        G_OBJECT_CLASS (p0_generator_parent_class)->finalize (object);
}

P0Generator *
p0_generator_new (GUPnPDevice *device,
                  P0Feedback  *feedback)
{
        P0Generator      *generator;
        GUPnPServiceInfo *service;

        g_return_val_if_fail (GUPNP_IS_DEVICE (device), NULL);
        g_return_val_if_fail (IS_P0_FEEDBACK (feedback), NULL);

        generator = g_object_new (TYPE_P0_GENERATOR, NULL);

        generator->feedback = g_object_ref (feedback);

        service = gupnp_device_info_get_service (GUPNP_DEVICE_INFO (device),
                                                 "urn:schemas-raumfeld-com:service:RaumfeldGenerator:1");

        generator->service = service;

        g_signal_connect (service, "action-invoked::SubscribeToFeedback",
                          G_CALLBACK (p0_generator_subscribe_to_feedback),
                          generator);

        g_signal_connect (service, "action-invoked::UnsubscribeFromFeedback",
                          G_CALLBACK (p0_generator_unsubscribe_from_feedback),
                          generator);

        return generator;
}

static void
p0_generator_subscribe_to_feedback (GUPnPService       *service,
                                    GUPnPServiceAction *action,
                                    P0Generator        *generator)
{
        guint  instance_id = 0;
	gchar *client_ip   = NULL;
	guint  client_port = 0;
        guint  timeout     = 300;  /* 5 minutes */

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "InstanceID", G_TYPE_UINT,   &instance_id,
                                  "IP",         G_TYPE_STRING, &client_ip,
                                  "Port",       G_TYPE_UINT,   &client_port,
                                  "Timeout",    G_TYPE_UINT,   &timeout,
                                  NULL);

        if (instance_id != 0) {
                gupnp_service_action_return_error (action,
                                                   ((guint) (702)),
                                                   "Invalid instance ID");
                goto out;
        }

        if (! client_ip || ! client_port || ! timeout) {
                gupnp_service_action_return_error (action,
                                                   ((guint) (402)),
                                                   "Invalid parameters");
                goto out;
        }

        p0_feedback_subscribe (generator->feedback,
                               client_ip, client_port, timeout);
        gupnp_service_action_return (action);

      out:
        g_free (client_ip);
}

static void
p0_generator_unsubscribe_from_feedback (GUPnPService       *service,
                                        GUPnPServiceAction *action,
                                        P0Generator        *generator)
{
        guint  instance_id = 0;
	gchar *client_ip   = NULL;
	guint  client_port = 0;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "InstanceID", G_TYPE_UINT,   &instance_id,
                                  "IP",         G_TYPE_STRING, &client_ip,
                                  "Port",       G_TYPE_INT,    &client_port,
                                  NULL);

        if (instance_id != 0) {
                gupnp_service_action_return_error (action,
                                                   ((guint) (702)),
                                                   "Invalid instance ID");
                goto out;
        }

        if (! client_ip || ! client_port) {
                gupnp_service_action_return_error (action,
                                                   ((guint) (402)),
                                                   "Invalid parameters");
                goto out;
        }

        p0_feedback_unsubscribe (generator->feedback, client_ip, client_port);
        gupnp_service_action_return (action);

      out:
        g_free (client_ip);
}
