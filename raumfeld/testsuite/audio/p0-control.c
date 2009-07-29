/*
 * P0Control:
 *
 * This class implements the RenderingControl service
 */

#include <string.h>

#include <raumfeld/dlna.h>
#include <raumfeld/time.h>

#include "p0-renderer-types.h"
#include "p0-control.h"
#include "p0-mixer.h"
#include "p0-alsa.h"
#include "p0-alsa-tools.h"


struct _P0Control
{
        GObject           parent_instance;

        GUPnPServiceInfo *service;
        DlnaChangeLog    *change_log;
        P0Mixer          *mixer;
        P0Alsa           *alsa;
        gchar            *outStreamURL;
};


static void  p0_control_dispose         (GObject            *object);
static void  p0_control_finalize        (GObject            *object);

static void  p0_control_volume_changed  (P0Mixer            *mixer,
                                         P0Control          *control);
static void  p0_control_mute_changed    (P0Mixer            *mixer,
                                         P0Control          *control);

static void  p0_control_get_volume      (GUPnPService       *service,
                                         GUPnPServiceAction *action,
                                         P0Control          *control);
static void  p0_control_set_volume      (GUPnPService       *service,
                                         GUPnPServiceAction *action,
                                         P0Control          *control);
static void  p0_control_get_filter      (GUPnPService       *service,
                                         GUPnPServiceAction *action,
                                         P0Control          *control);
static void  p0_control_set_filter      (GUPnPService       *service,
                                         GUPnPServiceAction *action,
                                         P0Control          *control);
static void  p0_control_get_mute        (GUPnPService       *service,
                                         GUPnPServiceAction *action,
                                         P0Control          *control);
static void  p0_control_set_mute        (GUPnPService       *service,
                                         GUPnPServiceAction *action,
                                         P0Control          *control);

static void  p0_control_get_last_change (GUPnPService       *service,
                                         const gchar        *variable,
                                         GValue             *value,
                                         P0Control          *control);

static void  p0_control_get_out_stream_url
                                        (GUPnPService       *service,
                                         GUPnPServiceAction *action,
                                         P0Control          *control);




G_DEFINE_TYPE (P0Control, p0_control, G_TYPE_OBJECT)


static void
p0_control_class_init (P0ControlClass *klass)
{
        GObjectClass *object_class = G_OBJECT_CLASS (klass);

        object_class->dispose  = p0_control_dispose;
        object_class->finalize = p0_control_finalize;
}


static void
p0_control_init (P0Control *control)
{
}

static void
p0_control_dispose (GObject *object)
{
        P0Control *control = P0_CONTROL (object);

        if (control->mixer) {
                g_object_unref (control->mixer);
                control->mixer = NULL;
        }

        G_OBJECT_CLASS (p0_control_parent_class)->dispose (object);
}

static void
p0_control_finalize (GObject *object)
{
        P0Control *control = P0_CONTROL (object);

        g_free (control->outStreamURL);

        g_object_unref (control->change_log);
        g_object_unref (control->service);

        G_OBJECT_CLASS (p0_control_parent_class)->finalize (object);
}

P0Control *
p0_control_new (GUPnPDevice *device)
{
        P0Control        *control;
        GUPnPServiceInfo *service;

        g_return_val_if_fail (GUPNP_IS_DEVICE (device), NULL);

        control = g_object_new (TYPE_P0_CONTROL, NULL);

        service = gupnp_device_info_get_service (GUPNP_DEVICE_INFO (device),
                                                 "urn:schemas-upnp-org:service:RenderingControl:1");

        control->service = service;

        g_signal_connect (service, "action-invoked::GetVolume",
                          G_CALLBACK (p0_control_get_volume),
                          control);
        g_signal_connect (service, "action-invoked::SetVolume",
                          G_CALLBACK (p0_control_set_volume),
                          control);
        g_signal_connect (service, "action-invoked::SetFilter",
                          G_CALLBACK (p0_control_set_filter),
                          control);
        g_signal_connect (service, "action-invoked::GetFilter",
                          G_CALLBACK (p0_control_get_filter),
                          control);
        g_signal_connect (service, "action-invoked::GetMute",
                          G_CALLBACK (p0_control_get_mute),
                          control);
        g_signal_connect (service, "action-invoked::SetMute",
                          G_CALLBACK (p0_control_set_mute),
                          control);

        /* setup last change callback mechanism*/
        g_signal_connect (service, "query-variable::LastChange",
                          G_CALLBACK (p0_control_get_last_change),
                          control);

        /* set up proprietary stuff */
        g_signal_connect (service, "action-invoked::GetOutStreamURL",
                                  G_CALLBACK (p0_control_get_out_stream_url),
                                  control);

        control->change_log = dlna_change_log_new (GUPNP_SERVICE (service));

        return control;
}

void
p0_control_set_mixer (P0Control *control,
                      P0Mixer   *mixer)
{
       g_return_if_fail (IS_P0_CONTROL (control));
       g_return_if_fail (IS_P0_MIXER (mixer));
       g_return_if_fail (control->mixer == NULL);

       control->mixer = g_object_ref (mixer);

       g_signal_connect_object (control->mixer, "volume-changed",
                                G_CALLBACK (p0_control_volume_changed),
                                control, 0);
       g_signal_connect_object (control->mixer, "mute-changed",
                                G_CALLBACK (p0_control_mute_changed),
                                control, 0);
}

void
p0_control_set_alsa (P0Control *control,
                     P0Alsa    *alsa)
{
       g_return_if_fail (IS_P0_CONTROL (control));
       g_return_if_fail (IS_P0_ALSA(alsa));
       g_return_if_fail (control->alsa == NULL);

       control->alsa = g_object_ref (alsa);

}


static void
p0_control_volume_changed (P0Mixer   *mixer,
                           P0Control *control)
{
        dlna_change_log_add (control->change_log,
                             "Volume", "%u", p0_mixer_get_volume (mixer));
}

static void
p0_control_mute_changed (P0Mixer   *mixer,
                         P0Control *control)
{
        dlna_change_log_add_boolean (control->change_log,
                                     "Mute", p0_mixer_get_mute (mixer));
}

static void
p0_control_get_volume (GUPnPService       *service,
                       GUPnPServiceAction *action,
                       P0Control          *control)
{
        guint  instance_id = 0;
        gchar *channel     = NULL;
        guint  volume      = 0;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "InstanceID", G_TYPE_UINT,   &instance_id,
                                  "Channel",    G_TYPE_STRING, &channel,
                                  NULL);

        if (instance_id != 0) {
                gupnp_service_action_return_error (action,
                                                   ((guint) (702)),
                                                   "Invalid instance ID");
                goto out;
        }

        if (! control->mixer) {
                // FIXME: error code
                gupnp_service_action_return_error ( action,
                                                    ((guint) (501)),
                                                    "not implemented");
                goto out;
        }

        if (g_ascii_strcasecmp (channel, "master")) {
                gupnp_service_action_return_error (action,
                                                   ((guint) (402)),
                                                   "Invalid channel");
                goto out;
        }

        volume = p0_mixer_get_volume (control->mixer);
        gupnp_service_action_set (action,
                                  "CurrentVolume", G_TYPE_UINT, volume,
                                  NULL);
        gupnp_service_action_return (action);

      out:
        g_free (channel);
}

static void
p0_control_set_volume (GUPnPService       *service,
                       GUPnPServiceAction *action,
                       P0Control          *control)
{
        guint  instance_id = 0;
        gchar *channel     = NULL;
        guint  volume      = 0;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "InstanceID",    G_TYPE_UINT,   &instance_id,
                                  "Channel",       G_TYPE_STRING, &channel,
                                  "DesiredVolume", G_TYPE_UINT,   &volume,
                                  NULL);

        if (instance_id != 0) {
                gupnp_service_action_return_error (action,
                                                   ((guint) (702)),
                                                   "Invalid instance ID");
                goto out;
        }

        if (! control->mixer) {
                gupnp_service_action_return_error ( action,
                                                    ((guint) (501)),
                                                    "not implemented");
                goto out;
        }

        if (g_ascii_strcasecmp (channel, "master")) {
                gupnp_service_action_return_error (action,
                                                   ((guint) (402)),
                                                   "Invalid channel");
                goto out;
        }

        p0_mixer_set_volume (control->mixer, volume);
        gupnp_service_action_return (action);

      out:
        g_free (channel);
}


static void
p0_control_get_mute (GUPnPService       *service,
                     GUPnPServiceAction *action,
                     P0Control          *control)
{
        guint     instance_id = 0;
        gchar    *channel     = NULL;
        gboolean  mute        = FALSE;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "InstanceID", G_TYPE_UINT,   &instance_id,
                                  "Channel",    G_TYPE_STRING, &channel,
                                  NULL);

        if (instance_id != 0) {
                gupnp_service_action_return_error (action,
                                                   ((guint) (702)),
                                                   "Invalid instance ID");
                goto out;
        }

        if (! control->mixer) {
                gupnp_service_action_return_error ( action,
                                                    ((guint) (501)),
                                                    "not implemented");
                goto out;
        }

        if (g_ascii_strcasecmp (channel, "master")) {
                gupnp_service_action_return_error (action,
                                                   ((guint) (402)),
                                                   "Invalid channel");
                goto out;
        }

        mute = p0_mixer_get_mute (control->mixer);
        gupnp_service_action_set (action,
                                  "CurrentMute", G_TYPE_BOOLEAN, mute,
                                  NULL);
        gupnp_service_action_return (action);

      out:
        g_free (channel);
}

static void
p0_control_set_mute (GUPnPService       *service,
                     GUPnPServiceAction *action,
                     P0Control          *control)
{
        guint    instance_id = 0;
        gchar   *channel     = NULL;
        gboolean  mute       = FALSE;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "InstanceID",  G_TYPE_UINT,    &instance_id,
                                  "Channel",     G_TYPE_STRING,  &channel,
                                  "DesiredMute", G_TYPE_BOOLEAN, &mute,
                                  NULL);

        if (instance_id != 0) {
                gupnp_service_action_return_error (action,
                                                   ((guint) (702)),
                                                   "Invalid instance ID");
                goto out;
        }

        if (! control->mixer) {
                gupnp_service_action_return_error ( action,
                                                    ((guint) (501)),
                                                    "not implemented");
                goto out;
        }

        if (g_ascii_strcasecmp (channel, "master")) {
                gupnp_service_action_return_error (action,
                                                   ((guint) (402)),
                                                   "Invalid channel");
                goto out;
        }

        p0_mixer_set_mute (control->mixer, mute);
        gupnp_service_action_return (action);

      out:
        g_free (channel);
}

/************************
 * proprietary stuff
 ************************/

static void
p0_control_get_out_stream_url (GUPnPService       *service,
                               GUPnPServiceAction *action,
                               P0Control          *control)
{
        gupnp_service_action_set (action,
                                  "URL", G_TYPE_STRING, control->outStreamURL,
                                  NULL);
        gupnp_service_action_return (action);
}

void
p0_control_set_out_stream_adress (P0Control  *control,
                                  const char *ip,
                                  int         port)
{
        g_return_if_fail (IS_P0_CONTROL (control));
        g_return_if_fail (ip != NULL);

        g_free (control->outStreamURL);
        control->outStreamURL = g_strdup_printf ("http://%s:%d", ip, port);
}



static void
p0_control_set_filter (GUPnPService       *service,
                       GUPnPServiceAction *action,
                       P0Control          *control)
{
        guint  instance_id = 0;
        gfloat  lowdb      = 0.0;
        gfloat  middb      = 0.0;
        gfloat  highdb      = 0.0;


        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "InstanceID",    G_TYPE_UINT,   &instance_id,
                                  "Lowdb",         G_TYPE_FLOAT,   &lowdb,
                                  "Middb",         G_TYPE_FLOAT,   &middb,
                                  "Highdb",        G_TYPE_FLOAT,   &highdb,
                                  NULL);

        if (instance_id != 0) {
                gupnp_service_action_return_error (action,
                                                   ((guint) (702)),
                                                   "Invalid instance ID");
                goto out;
        }

        if (! control->alsa) {
                gupnp_service_action_return_error ( action,
                                                    ((guint) (501)),
                                                    "not implemented");
                goto out;
        }


        p0_alsa_set_filter(control->alsa,
                           lowdb,
                           middb,
                           highdb);

        gupnp_service_action_return (action);

      out:
              return;
}

static void
p0_control_get_filter (GUPnPService       *service,
                       GUPnPServiceAction *action,
                       P0Control          *control)
{
        guint   instance_id = 0;
        gfloat  lowdb      = 0.0;
        gfloat  middb      = 0.0;
        gfloat  highdb      = 0.0;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "InstanceID", G_TYPE_UINT,   &instance_id,
                                  NULL);

        if (instance_id != 0) {
                gupnp_service_action_return_error (action,
                                                   ((guint) (702)),
                                                   "Invalid instance ID");
                goto out;
        }

        if (!control->alsa) {
                // FIXME: error code
                gupnp_service_action_return_error ( action,
                                                    ((guint) (501)),
                                                    "not implemented");
                goto out;
        }

        p0_alsa_get_filter(control->alsa,
                           &lowdb,
                           &middb,
                           &highdb);

        gupnp_service_action_set (action,
                                  "Lowdb",  G_TYPE_FLOAT, lowdb,
                                  "Middb",  G_TYPE_FLOAT, middb,
                                  "Highdb", G_TYPE_FLOAT, highdb,
                                  NULL);

        gupnp_service_action_return (action);

      out:
              return;

}

/***********************
 * last change stuff
 ***********************/

static void
p0_control_get_last_change (GUPnPService *service,
                            const gchar  *variable,
                            GValue       *value,
                            P0Control    *control)
{
        DlnaChangeLog *log;
        guint          volume = 100;
        gboolean       mute   = FALSE;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        if (control->mixer) {
               volume = p0_mixer_get_volume (control->mixer);
               mute   = p0_mixer_get_mute   (control->mixer);
        }

        log = dlna_change_log_new (service);

        dlna_change_log_add (log, "Volume", "%u", volume);
        dlna_change_log_add_boolean (log, "Mute", mute);

        dlna_change_log_finish (log, value);
        g_object_unref (log);
}

