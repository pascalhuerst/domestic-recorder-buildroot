/*
 * P0Manager:
 *
 * This class implements the ConnectionManager service
 */

#include <string.h>

#include <raumfeld/dlna.h>

#include "p0-renderer-types.h"
#include "p0-gst.h"
#include "p0-manager.h"


struct _P0Manager
{
        GObject           parent_instance;

        GUPnPServiceInfo *service;
};


static void  p0_manager_finalize             (GObject            *object);

static void  on_get_protocol_info            (GUPnPService       *service,
                                              GUPnPServiceAction *action);
static void  on_get_current_connection_ids   (GUPnPService       *service,
                                              GUPnPServiceAction *action);
static void  on_get_current_connection_info  (GUPnPService       *service,
                                              GUPnPServiceAction *action);
static void  on_query_source_protocol_info   (GUPnPService       *service,
                                              const char         *variable,
                                              GValue             *value);
static void  on_query_sink_protocol_info     (GUPnPService       *service,
                                              const char         *variable,
                                              GValue             *value);
static void  on_query_current_connection_ids (GUPnPService       *service,
                                              const char         *variable,
                                              GValue             *value);



G_DEFINE_TYPE (P0Manager, p0_manager, G_TYPE_OBJECT)

static void
p0_manager_class_init (P0ManagerClass *klass)
{
        GObjectClass *object_class = G_OBJECT_CLASS (klass);

        object_class->finalize = p0_manager_finalize;
}


static void
p0_manager_init (P0Manager *manager)
{
}

static void
p0_manager_finalize (GObject *object)
{
        P0Manager *manager = P0_MANAGER (object);

        g_object_unref (manager->service);

        G_OBJECT_CLASS (p0_manager_parent_class)->finalize (object);
}

P0Manager *
p0_manager_new (GUPnPDevice *device)
{
        P0Manager        *manager;
        GUPnPServiceInfo *service;

        g_return_val_if_fail (GUPNP_IS_DEVICE (device), NULL);

        manager = g_object_new (TYPE_P0_MANAGER, NULL);

        service = gupnp_device_info_get_service (GUPNP_DEVICE_INFO (device),
                                                 "urn:schemas-upnp-org:service:ConnectionManager:1");

        manager->service = service;

        g_signal_connect (service, "action-invoked::GetProtocolInfo",
                          G_CALLBACK (on_get_protocol_info),
                          manager);
        g_signal_connect (service, "action-invoked::GetCurrentConnectionIDs",
                          G_CALLBACK (on_get_current_connection_ids),
                          manager);
        g_signal_connect (service, "action-invoked::GetCurrentConnectionInfo",
                          G_CALLBACK (on_get_current_connection_info),
                          manager);
        g_signal_connect (service, "query-variable::SourceProtocolInfo",
                          G_CALLBACK (on_query_source_protocol_info),
                          manager);
        g_signal_connect (service, "query-variable::SinkProtocolInfo",
                          G_CALLBACK (on_query_sink_protocol_info),
                          manager);
        g_signal_connect (service, "query-variable::CurrentConnectionIDs",
                          G_CALLBACK (on_query_current_connection_ids),
                          manager);

        return manager;
}

static void
on_get_protocol_info (GUPnPService       *service,
                      GUPnPServiceAction *action)
{
        gchar *supportedProtocols = p0_gst_get_supported_protocols_string();

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_set (action,
                                  "Source", G_TYPE_STRING, "",
                                  "Sink",   G_TYPE_STRING, supportedProtocols,
                                  NULL);

        gupnp_service_action_return (action);
        g_free(supportedProtocols);
}

static void
on_get_current_connection_ids (GUPnPService       *service,
                               GUPnPServiceAction *action)
{
        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_set (action,
                                  "ConnectionIDs", G_TYPE_STRING, "0",
                                  NULL);

        gupnp_service_action_return (action);
}

static void
on_get_current_connection_info (GUPnPService       *service,
                                GUPnPServiceAction *action)
{
        gint connection_id = 0;

        g_print ("->UPnP: %s called\n", G_STRFUNC);

        gupnp_service_action_get (action,
                                  "ConnectionID", G_TYPE_INT, &connection_id,
                                  NULL);

        if (connection_id != 0) {
                g_printerr ("->UPnP: %s: connection_id!=0??\n", G_STRFUNC);

                gupnp_service_action_return_error (action,
                                                   ((guint) (706)),
                                                   "Invalid connection reference");
                return;
        }

        /* FIXME: set Protocol Info,
         * maybe PeerConnection has also to be set,
         * Status is maybe also not always ok
         */

        gupnp_service_action_set (action,
                                  "RcsID",                 G_TYPE_INT,    0,
                                  "AVTransportID",         G_TYPE_INT,    0,
                                  "ProtocolInfo",          G_TYPE_STRING, "http-get:*:mp3:*",
                                  "PeerConnectionManager", G_TYPE_STRING, "",
                                  "PeerConnectionID",      G_TYPE_INT,    -1,
                                  "Direction",             G_TYPE_STRING, "Input",
                                  "Status",                G_TYPE_STRING, "OK",
                                  NULL);

        gupnp_service_action_return (action);
}


static void
on_query_source_protocol_info (GUPnPService *service,
                               const char   *variable,
                               GValue       *value)
{
        g_print ("->UPnP: %s called\n", G_STRFUNC);

        g_value_init (value, G_TYPE_STRING);
        g_value_set_static_string (value, "");
}

static void
on_query_sink_protocol_info (GUPnPService *service,
                             const char   *variable,
                             GValue       *value)
{
        g_print ("->UPnP: %s called\n", G_STRFUNC);

        g_value_init (value, G_TYPE_STRING);
        g_value_take_string (value, p0_gst_get_supported_protocols_string());
}

static void
on_query_current_connection_ids (GUPnPService *service,
                                 const char   *variable,
                                 GValue       *value)
{
        g_print ("->UPnP: %s called\n", G_STRFUNC);

        g_value_init (value, G_TYPE_INT);
        g_value_set_int (value, 0);
}
