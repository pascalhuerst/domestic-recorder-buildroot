/*
 * P0Transport:
 *
 * This class implements the AVTransport service
 */

#include <string.h>
#include <sys/time.h>

#include <raumfeld/dlna.h>

#include "p0-renderer-types.h"
#include "p0-gst.h"
#include "p0-transport.h"


struct _P0Transport
{
        GObject             parent_instance;

        gchar              *time_service;

        GUPnPServiceInfo   *service;

        gchar              *current_uri;
        gchar              *current_uri_metadata;

        DlnaTransportState  transport_state;
        DlnaPlayMode        play_mode;
        DlnaChangeLog      *change_log;

        struct timeval      last_trigger_time;
};


/* Signals for communication with the rest of the world */
enum
{
        SET_URI_CALLED,
        PLAY_CALLED,
        STOP_CALLED,
        TRIGGER_SET,
        LAST_SIGNAL
};


/*  sanity check  */
static GThread *main_thread = NULL;


static void p0_transport_finalize                (GObject            *object);

static void p0_transport_set_transport_state     (P0Transport        *transport,
                                                  DlnaTransportState  state);
static void p0_transport_set_uri                 (P0Transport        *transport,
                                                  const gchar        *uri,
                                                  const gchar        *metadata);
static const gchar *
           p0_transport_get_transport_state_name (P0Transport        *transport);
static const gchar *
           p0_transport_get_playmode_name        (P0Transport        *transport);


/* callbacks for UPnP Action */

static void on_set_av_transport_uri             (GUPnPService       *service,
                                                 GUPnPServiceAction *action,
                                                 P0Transport        *transport);
static void on_get_media_info                   (GUPnPService       *service,
                                                 GUPnPServiceAction *action,
                                                 P0Transport        *transport);
static void on_get_transport_info               (GUPnPService       *service,
                                                 GUPnPServiceAction *action,
                                                 P0Transport        *transport);
static void on_get_position_info                (GUPnPService       *service,
                                                 GUPnPServiceAction *action,
                                                 P0Transport        *transport);
static void on_get_device_capabilities          (GUPnPService       *service,
                                                 GUPnPServiceAction *action,
                                                 P0Transport        *transport);
static void on_get_transport_settings           (GUPnPService       *service,
                                                 GUPnPServiceAction *action,
                                                 P0Transport        *transport);
static void on_stop                             (GUPnPService       *service,
                                                 GUPnPServiceAction *action,
                                                 P0Transport        *transport);
static void on_play                             (GUPnPService       *service,
                                                 GUPnPServiceAction *action,
                                                 P0Transport        *transport);
static void on_seek                             (GUPnPService       *service,
                                                 GUPnPServiceAction *action,
                                                 P0Transport        *transport);
static void on_next                             (GUPnPService       *service,
                                                 GUPnPServiceAction *action,
                                                 P0Transport        *transport);
static void on_previous                         (GUPnPService       *service,
                                                 GUPnPServiceAction *action,
                                                 P0Transport        *transport);
static void on_set_play_mode                    (GUPnPService       *service,
                                                 GUPnPServiceAction *action,
                                                 P0Transport        *transport);
static void on_get_current_transport_actions    (GUPnPService       *service,
                                                 GUPnPServiceAction *action,
                                                 P0Transport        *transport);

/* proprietary functions */
static void on_set_next_start_trigger_time      (GUPnPService       *service,
                                                 GUPnPServiceAction *action,
                                                 P0Transport        *transport);

/* last change callback function*/
static void p0_transport_get_last_change        (GUPnPService       *service,
                                                 const gchar        *variable,
                                                 GValue             *value,
                                                 P0Transport        *transport);



G_DEFINE_TYPE (P0Transport, p0_transport, G_TYPE_OBJECT)

static guint p0_transport_signals[LAST_SIGNAL] = { 0 };


static void
p0_transport_class_init (P0TransportClass *klass)
{
        GObjectClass *object_class = G_OBJECT_CLASS (klass);

        object_class->finalize = p0_transport_finalize;

        p0_transport_signals[SET_URI_CALLED] =
                g_signal_new ("set-uri-called",
                              G_TYPE_FROM_CLASS (klass),
                              G_SIGNAL_RUN_FIRST,
                              G_STRUCT_OFFSET (P0TransportClass, set_uri_called),
                              NULL, NULL,
                              g_cclosure_marshal_VOID__STRING,
                              G_TYPE_NONE, 1, G_TYPE_STRING);

        p0_transport_signals[PLAY_CALLED] =
                g_signal_new ("play-called",
                              G_TYPE_FROM_CLASS (klass),
                              G_SIGNAL_RUN_FIRST,
                              G_STRUCT_OFFSET (P0TransportClass, play_called),
                              NULL, NULL,
                              g_cclosure_marshal_VOID__VOID,
                              G_TYPE_NONE, 0);

        p0_transport_signals[STOP_CALLED] =
                g_signal_new ("stop-called",
                              G_TYPE_FROM_CLASS (klass),
                              G_SIGNAL_RUN_FIRST,
                              G_STRUCT_OFFSET (P0TransportClass, stop_called),
                              NULL, NULL,
                              g_cclosure_marshal_VOID__VOID,
                              G_TYPE_NONE,0);

        p0_transport_signals[TRIGGER_SET] =
                g_signal_new ("trigger-set",
                              G_TYPE_FROM_CLASS (klass),
                              G_SIGNAL_RUN_FIRST,
                              G_STRUCT_OFFSET (P0TransportClass, trigger_set),
                              NULL, NULL,
                              g_cclosure_marshal_VOID__STRING,
                              G_TYPE_NONE, 1, G_TYPE_STRING);
}


static void
p0_transport_init (P0Transport *transport)
{
        transport->transport_state = DLNA_TRANSPORT_STATE_NO_MEDIA_PRESENT;
        transport->play_mode       = DLNA_PLAY_MODE_NORMAL;

        g_print ("--->CurrentTransportState: %s\n",
                 p0_transport_get_transport_state_name (transport));

        main_thread = g_thread_self ();
}

static void
p0_transport_finalize (GObject *object)
{
        P0Transport *transport = P0_TRANSPORT (object);

        g_object_unref (transport->change_log);
        g_object_unref (transport->service);

        g_free (transport->current_uri);
        g_free (transport->current_uri_metadata);
        g_free (transport->time_service);

        G_OBJECT_CLASS (p0_transport_parent_class)->finalize (object);
}

P0Transport *
p0_transport_new (GUPnPDevice *device,
                  const gchar *time_service)
{
        P0Transport      *transport;
        GUPnPServiceInfo *service;

        g_return_val_if_fail (GUPNP_IS_DEVICE (device), NULL);
        g_return_val_if_fail (time_service != NULL, NULL);

        transport = g_object_new (TYPE_P0_TRANSPORT, NULL);

        transport->time_service = g_strdup (time_service);

        /* setup all callbacks for AV Transport Service */
        service = gupnp_device_info_get_service (GUPNP_DEVICE_INFO (device),
                                                 "urn:schemas-upnp-org:service:AVTransport:1");
        transport->service = service;

        g_signal_connect (service, "action-invoked::SetAVTransportURI",
                          G_CALLBACK (on_set_av_transport_uri),
                          transport);
        g_signal_connect (service, "action-invoked::GetMediaInfo",
                          G_CALLBACK (on_get_media_info),
                          transport);
        g_signal_connect (service, "action-invoked::GetTransportInfo",
                          G_CALLBACK (on_get_transport_info),
                          transport);
        g_signal_connect (service, "action-invoked::GetPositionInfo",
                          G_CALLBACK (on_get_position_info),
                          transport);
        g_signal_connect (service, "action-invoked::GetGetDeviceCapabilities",
                          G_CALLBACK (on_get_device_capabilities),
                          transport);
        g_signal_connect (service, "action-invoked::GetTransportSettings",
                          G_CALLBACK (on_get_transport_settings),
                          transport);
        g_signal_connect (service, "action-invoked::Stop",
                          G_CALLBACK (on_stop),
                          transport);
        g_signal_connect (service, "action-invoked::Play",
                          G_CALLBACK (on_play),
                          transport);
        g_signal_connect (service, "action-invoked::Seek",
                          G_CALLBACK (on_seek),
                          transport);
        g_signal_connect (service, "action-invoked::Next",
                          G_CALLBACK (on_next),
                          transport);
        g_signal_connect (service, "action-invoked::Previous",
                          G_CALLBACK (on_previous),
                          transport);
        g_signal_connect (service, "action-invoked::SetPlayMode",
                          G_CALLBACK (on_set_play_mode),
                          transport);
        g_signal_connect (service, "action-invoked::GetCurrentTransportActions",
                          G_CALLBACK (on_get_current_transport_actions),
                          transport);

        /* proprietary AV Transport actions */
        g_signal_connect (service, "action-invoked::SetNextStartTriggerTime",
                          G_CALLBACK (on_set_next_start_trigger_time),
                          transport);

        /* setup last change callback mechanism*/
        g_signal_connect (service, "query-variable::LastChange",
                          G_CALLBACK (p0_transport_get_last_change),
                          transport);

        transport->change_log = dlna_change_log_new (GUPNP_SERVICE (service));

        return transport;
}

void
p0_transport_notify_playstate (P0Transport *transport,
                               PlayState    new_playstate)
{
        g_return_if_fail (IS_P0_TRANSPORT (transport));

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        g_assert (g_thread_self () == main_thread);

        switch (new_playstate) {
        case PLAYING:
                p0_transport_set_transport_state (transport,
                                                  DLNA_TRANSPORT_STATE_PLAYING);
                break;

        case STOPPED:
                p0_transport_set_transport_state (transport,
                                                  DLNA_TRANSPORT_STATE_STOPPED);
                break;

        default:
                g_assert_not_reached ();
        }
}


void
p0_transport_notify_buffer_filled (P0Transport *transport)
{
        static guint counter = 0;

        g_return_if_fail (IS_P0_TRANSPORT (transport));

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        g_assert (g_thread_self () == main_thread);

        gupnp_service_notify (GUPNP_SERVICE (transport->service),
                              "BufferFilled", G_TYPE_UINT, counter++,
                              NULL);
}

static const gchar *
p0_transport_get_transport_state_name (P0Transport *transport)
{
        return dlna_enum_value_get_name (DLNA_TYPE_TRANSPORT_STATE,
                                         "DLNA_TRANSPORT_STATE_",
                                         transport->transport_state);
}

static const gchar *
p0_transport_get_transport_actions (P0Transport *transport)
{
        switch (transport->transport_state) {
        case DLNA_TRANSPORT_STATE_STOPPED:
                return "Play";
                break;
        case DLNA_TRANSPORT_STATE_PLAYING:
                return "Stop";
                break;
        default:
                return "";
        }
}

static const gchar *
p0_transport_get_playmode_name (P0Transport *transport)
{
        return dlna_enum_value_get_name (DLNA_TYPE_PLAY_MODE,
                                         "DLNA_PLAY_MODE_",
                                         transport->play_mode);
}

static void
p0_transport_set_transport_state (P0Transport        *transport,
                                  DlnaTransportState  state)
{
        const gchar *state_name;
        const gchar *actions;

        if (transport->transport_state == state)
                return;

        transport->transport_state = state;

        state_name = p0_transport_get_transport_state_name (transport);
        actions    = p0_transport_get_transport_actions (transport);

        g_print ("--->CurrentTransportState: %s\n", state_name);

        dlna_change_log_add_literal (transport->change_log,
                                     "TransportState", state_name);
        dlna_change_log_add_literal (transport->change_log,
                                     "CurrentTransportActions", actions);
}

static void
p0_transport_set_uri (P0Transport *transport,
                      const gchar *uri,
                      const gchar *metadata)
{
        gchar *escaped_uri      = NULL;
        gchar *escaped_metadata = NULL;

        g_free (transport->current_uri);
        transport->current_uri = g_strdup (uri);

        g_free (transport->current_uri_metadata);
        transport->current_uri_metadata = g_strdup (metadata);

        if (transport->current_uri && strlen (transport->current_uri)) {
                p0_transport_set_transport_state (transport,
                                                 DLNA_TRANSPORT_STATE_STOPPED);
        } else {
                p0_transport_set_transport_state (transport,
                                                 DLNA_TRANSPORT_STATE_NO_MEDIA_PRESENT);
        }

        if (transport->current_uri)
                escaped_uri = g_markup_escape_text (transport->current_uri, -1);

        if (transport->current_uri_metadata)
                escaped_metadata = g_markup_escape_text (transport->current_uri_metadata, -1);

        dlna_change_log_add_literal(transport->change_log,
                                    "AVTransportURI", escaped_uri);
        dlna_change_log_add_literal(transport->change_log,
                                    "AVTransportURIMetaData", escaped_metadata);

        g_free(escaped_uri);
        g_free(escaped_metadata);

        g_signal_emit (transport,
                       p0_transport_signals[SET_URI_CALLED], 0,
                       transport->current_uri);
}


/*
 * AV Transport Callback
 *
 *
 * *****************************************/
static void
on_set_av_transport_uri (GUPnPService       *service,
                         GUPnPServiceAction *action,
                         P0Transport        *transport)
{
        guint  instance_id   = 0;
        gchar *uri           = NULL;
        gchar *uri_meta_data = NULL;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "InstanceID",         G_TYPE_UINT,   &instance_id,
                                  "CurrentURI",         G_TYPE_STRING, &uri,
                                  "CurrentURIMetaData", G_TYPE_STRING, &uri_meta_data,
                                  NULL);

        if (instance_id != 0) {
                g_print ("--->instance_id != 0 ??\n");

                gupnp_service_action_return_error (action,
                                                   ((guint) (706)),
                                                   "Invalid instance ID");
                goto out;
        }

        g_print ("--->CurrentURI: %s\n",uri);

        g_print ("--->CurrentURIMetaData: %s\n",uri_meta_data);

        if (transport->transport_state == DLNA_TRANSPORT_STATE_PLAYING) {
                g_print ("!!!--->cant't set uri, transport is playing!!\n");

                gupnp_service_action_return_error (action,
                                                   ((guint) (701)),
                                                   "Transition not available");
                goto out;
        }

        gupnp_service_action_return (action);

        p0_transport_set_uri (transport, uri, uri_meta_data);

      out:
        g_free (uri);
        g_free (uri_meta_data);
}


static void
on_get_media_info (GUPnPService       *service,
                   GUPnPServiceAction *action,
                   P0Transport        *transport)
{
        guint instance_id = 0;
        guint num_tracks;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "InstanceID", G_TYPE_UINT, &instance_id,
                                  NULL);

        if (instance_id != 0) {
                g_print ("--->instance_id != 0 ??\n");

                gupnp_service_action_return_error (action,
                                                   ((guint) (718)),
                                                   "Invalid instance ID");
                return;
        }

        /* FIXME: implement this correctly */
        num_tracks = (transport->transport_state <
                      DLNA_TRANSPORT_STATE_NO_MEDIA_PRESENT ? 1 : 0);

        gupnp_service_action_set (action,
                                  "NrTracks",           G_TYPE_UINT,   num_tracks,
                                  "MediaDuration",      G_TYPE_STRING, "0:00:00",
                                  "CurrentURI",         G_TYPE_STRING, transport->current_uri,
                                  "CurrentURIMetaData", G_TYPE_STRING, transport->current_uri_metadata,
                                  "NextURI",            G_TYPE_STRING, NULL,
                                  "NextURIMetaData",    G_TYPE_STRING, NULL,
                                  "PlayMedium",         G_TYPE_STRING, "Network",
                                  "RecordMedium",       G_TYPE_STRING, "NOT_IMPLEMENTED",
                                  "WriteStatus",        G_TYPE_STRING, "NOT_IMPLEMENTED",
                                  NULL);

        gupnp_service_action_return (action);
}


static void
on_get_transport_info (GUPnPService       *service,
                       GUPnPServiceAction *action,
                       P0Transport        *transport)
{
        guint        instance_id = 0;
        const gchar *state;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "InstanceID", G_TYPE_UINT, &instance_id,
                                  NULL);

        if (instance_id != 0) {
                g_print ("--->instance_id != 0 ??\n");

                gupnp_service_action_return_error (action,
                                                   ((guint) (718)),
                                                   "Invalid instance ID");
                return;
        }

        state = p0_transport_get_transport_state_name (transport);

        gupnp_service_action_set (action,
                                  "CurrentTransportState",  G_TYPE_STRING, state,
                                  "CurrentTransportStatus", G_TYPE_STRING, "OK",
                                  "CurrentSpeed",           G_TYPE_STRING, "1",
                                  NULL);

        gupnp_service_action_return (action);
}


static void
on_get_position_info (GUPnPService       *service,
                      GUPnPServiceAction *action,
                      P0Transport        *transport)
{
        // g_print ("->UPnP: %s called\n", G_STRFUNC);

        /* FIXME: implement */

        gupnp_service_action_return_error ( action,
                                            ((guint) (706)),
                                            "not implemented");
}

static void
on_get_device_capabilities (GUPnPService       *service,
                            GUPnPServiceAction *action,
                            P0Transport        *transport)
{
        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_set (action,
                                  "PlayMedia",       G_TYPE_STRING, "NETWORK",
                                  "RecMedia",        G_TYPE_STRING, "NONE",
                                  "RecQualityModes", G_TYPE_STRING, "NOT_IMPLEMENTED",
                                  NULL);

        gupnp_service_action_return (action);
}


static void
on_get_transport_settings (GUPnPService       *service,
                           GUPnPServiceAction *action,
                           P0Transport        *transport)
{
        guint        instance_id = 0;
        const gchar *mode;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "InstanceID", G_TYPE_UINT, &instance_id,
                                  NULL);

        if (instance_id != 0) {
                g_print ("--->instance_id != 0 ??\n");

                gupnp_service_action_return_error (action,
                                                   ((guint) (718)),
                                                   "Invalid instance ID");
                return;
        }

        mode = p0_transport_get_playmode_name (transport);

        gupnp_service_action_set (action,
                                  "PlayMode",       G_TYPE_STRING, mode,
                                  "RecQualityMode", G_TYPE_STRING, "NOT_IMPLEMENTED",
                                  NULL);

        gupnp_service_action_return (action);
}

static void
on_stop (GUPnPService       *service,
         GUPnPServiceAction *action,
         P0Transport        *transport)
{
        guint instance_id = 0;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "InstanceID", G_TYPE_UINT, &instance_id,
                                  NULL);

        if (instance_id != 0) {
                g_print ("--->instance_id != 0 ??\n");

                gupnp_service_action_return_error (action,
                                                   ((guint) (718)),
                                                   "Invalid instance ID");
                return;
        }

        gupnp_service_action_return (action);

        p0_transport_set_transport_state (transport,
                                         DLNA_TRANSPORT_STATE_STOPPED);

        g_signal_emit (transport, p0_transport_signals[STOP_CALLED], 0);
}

static void
on_play (GUPnPService       *service,
         GUPnPServiceAction *action,
         P0Transport        *transport)
{
        guint  instance_id = 0;
        gchar *speed       = NULL;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "InstanceID", G_TYPE_UINT,   &instance_id,
                                  "Speed",      G_TYPE_STRING, &speed,
                                  NULL);

        if (instance_id != 0) {
                g_print ("--->instance_id != 0 ??\n");

                gupnp_service_action_return_error (action,
                                                   ((guint) (718)),
                                                   "Invalid instance ID");
                goto out;
        }


        if (strcmp (speed, "1")) {
                g_print ("--->speed != 1??\n");

                gupnp_service_action_return_error (action,
                                                   ((guint) (717)),
                                                   "Unsupported play speed");
                goto out;
        }

        if (!transport->current_uri || !strlen(transport->current_uri)) {
                g_print ("--->no uri set\n");

                gupnp_service_action_return_error (action,
                                                   ((guint) (701)),
                                                   "Transition not available");

                goto out;
        }


        gupnp_service_action_return (action);

        p0_transport_set_transport_state (transport,
                                         DLNA_TRANSPORT_STATE_TRANSITIONING);

        g_signal_emit (transport, p0_transport_signals[PLAY_CALLED], 0);

     out:
        g_free (speed);
}

static void
on_seek (GUPnPService       *service,
         GUPnPServiceAction *action,
         P0Transport        *transport)
{
        g_print ("->UPnP: %s called\n", G_STRFUNC);

        /* FIXME: implement */

        gupnp_service_action_return_error ( action,
                                            ((guint) (706)),
                                            "not implemented");
}

static void
on_next (GUPnPService       *service,
         GUPnPServiceAction *action,
         P0Transport        *transport)
{
        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_return_error ( action,
                                            ((guint) (701)),
                                            "Transition not available");
}


static void
on_previous (GUPnPService       *service,
             GUPnPServiceAction *action,
             P0Transport        *transport)
{
        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_return_error ( action,
                                            ((guint) (701)),
                                            "Transition not available");
}

static void
on_set_play_mode (GUPnPService       *service,
                  GUPnPServiceAction *action,
                  P0Transport        *transport)
{
        DlnaPlayMode  mode        = DLNA_PLAY_MODE_UNKNOWN;
        guint         instance_id = 0;
        gchar        *name        = NULL;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "InstanceID",  G_TYPE_UINT,   &instance_id,
                                  "NewPlayMode", G_TYPE_STRING, &name,
                                  NULL);

        if (instance_id != 0) {
                g_print ("--->instance_id != 0 ??\n");

                gupnp_service_action_return_error (action,
                                                   ((guint) (718)),
                                                   "Invalid instance ID");
                goto out;
        }

        if (! name ||
            ! dlna_enum_get_value_by_name (DLNA_TYPE_PLAY_MODE,
                                           "DLNA_PLAY_MODE_", name,
                                           (gint *) &mode)) {
                gupnp_service_action_return_error (action,
                                                   ((guint) (402)),
                                                   "Invalid arguments");
                goto out;
        }


        if (mode != DLNA_PLAY_MODE_NORMAL) {
                gupnp_service_action_return_error ( action,
                                                    ((guint) (712)),
                                                    "Play mode not supported");
        }

      out:
        g_free (name);
}

static void
on_get_current_transport_actions (GUPnPService       *service,
                                  GUPnPServiceAction *action,
                                  P0Transport        *transport)
{
        guint        instance_id = 0;
        const gchar *actions;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "InstanceID", G_TYPE_UINT, &instance_id,
                                  NULL);

        if (instance_id != 0) {
                g_print ("--->instance_id != 0 ??\n");

                gupnp_service_action_return_error (action,
                                                   ((guint) (718)),
                                                   "Invalid instance ID");
                return;
        }

        g_print ("->UPnP: on_get_current_transport_actions called\n");

        actions = p0_transport_get_transport_actions (transport);

        gupnp_service_action_set (action,
                                  "Actions", G_TYPE_STRING, actions,
                                  NULL);

        gupnp_service_action_return (action);
}

/********************
 * Proprietary Functions
 ***********************************/

static void
on_set_next_start_trigger_time (GUPnPService       *service,
                                GUPnPServiceAction *action,
                                P0Transport        *transport)
{
        guint   instance_id       = 0;
        gchar  *time_service      = NULL;
        gchar  *next_trigger_time = NULL;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "InstanceID",  G_TYPE_UINT,   &instance_id,
                                  "TimeService", G_TYPE_STRING, &time_service,
                                  "StartTime",   G_TYPE_STRING, &next_trigger_time,
                                  NULL);

        if (instance_id != 0) {
                g_print ("--->instance_id != 0 ??\n");

                gupnp_service_action_return_error (action,
                                                   ((guint) (706)),
                                                   "Invalid instance ID");
                goto out;
        }

        if (! time_service || strcmp (time_service, transport->time_service)) {
                g_print ("--->unexpected time service ??\n");

                gupnp_service_action_return_error (action,
                                                   ((guint) (706)),
                                                   "Unexpected time service");
                goto out;
        }

        if (transport->transport_state != DLNA_TRANSPORT_STATE_PLAYING) {

                g_print ("--->UPnP Next Trigger Time Set To: %s\n",
                         next_trigger_time);

                sscanf (next_trigger_time, "%li:%li",
                        &transport->last_trigger_time.tv_sec,
                        &transport->last_trigger_time.tv_usec);

                g_signal_emit (transport,
                               p0_transport_signals[TRIGGER_SET], 0,
                               next_trigger_time);
        } else
                g_print ("!!!--->can't set next trigger time!, transport is in Playmode!\n");

        gupnp_service_action_return (action);

      out:
        g_free (time_service);
        g_free (next_trigger_time);
}


/***********************
 * last change stuff
 ***********************/

static void
p0_transport_get_last_change (GUPnPService *service,
                              const gchar  *variable,
                              GValue       *value,
                              P0Transport  *transport)
{
        DlnaChangeLog *log;
        gchar         *escaped_uri      = NULL;
        gchar         *escaped_metadata = NULL;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        log = dlna_change_log_new (service);

        if (transport->current_uri)
                escaped_uri = g_markup_escape_text (transport->current_uri, -1);

        if (transport->current_uri_metadata)
                escaped_metadata = g_markup_escape_text (transport->current_uri_metadata, -1);

        dlna_change_log_add_literal (log, "TransportState",
                                     p0_transport_get_transport_state_name (transport));

        /* FIXME error handling*/
        dlna_change_log_add_literal (log, "TransportStatus", "OK");

        dlna_change_log_add_literal (log, "TransportPlaySpeed", "1");

        dlna_change_log_add_literal (log, "CurrentTrack",
                                     transport->current_uri ? "1" : "0");
        dlna_change_log_add_literal (log, "CurrentTrackDuration", "infinite");
        dlna_change_log_add_literal (log, "AVTransportURI", escaped_uri);
        dlna_change_log_add_literal (log, "AVTransportURIMetaData", escaped_metadata);

        dlna_change_log_add_literal (log, "RelativeTimePosition", "infinite");
        dlna_change_log_add_literal (log, "AbsoluteTimePosition", "infinite");
        dlna_change_log_add_literal (log, "RelativeCounterPosition", "1");
        dlna_change_log_add_literal (log, "AbsoluteCounterPosition", "1");

        dlna_change_log_add_literal (log, "PossiblePlaybackStorageMedia", "NETWORK");
        dlna_change_log_add_literal (log, "PossibleRecordStorageMedia", "NONE");
        dlna_change_log_add_literal (log, "PossibleRecordQualityModes", "NOT_IMPLEMENTED");

        dlna_change_log_add_literal (log, "CurrentPlayMode",
                                     p0_transport_get_playmode_name (transport));
        dlna_change_log_add_literal (log, "CurrentRecordQualityMode", "NOT_IMPLEMENTED");
        dlna_change_log_add_literal (log, "CurrentTransportActions",
                                     p0_transport_get_transport_actions (transport));

        g_free (escaped_uri);
        g_free (escaped_metadata);

        dlna_change_log_finish (log, value);
        g_object_unref (log);
}
