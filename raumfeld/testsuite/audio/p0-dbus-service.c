/*
 * P0DBusService:
 *
 * This class provides the DBus service.
 */

#include <dbus/dbus-glib.h>

#include "p0-renderer-types.h"
#include "p0-dbus-service.h"
#include "p0-dbus-service-glue.h"


struct _P0DBusService
{
        GObject   parent_instance;

        gboolean  active;
};

enum
{
        ACTIVE_CHANGED,
        LAST_SIGNAL
};


G_DEFINE_TYPE (P0DBusService, p0_dbus_service, G_TYPE_OBJECT)

static guint p0_dbus_service_signals[LAST_SIGNAL] = { 0 };


static void
p0_dbus_service_class_init (P0DBusServiceClass* klass)
{
        p0_dbus_service_signals[ACTIVE_CHANGED] =
                g_signal_new ("active-changed",
                              G_TYPE_FROM_CLASS (klass),
                              G_SIGNAL_RUN_FIRST,
                              0,
                              NULL, NULL,
                              g_cclosure_marshal_VOID__BOOLEAN,
                              G_TYPE_NONE, 1, G_TYPE_BOOLEAN);

        dbus_g_object_type_install_info (G_TYPE_FROM_CLASS (klass),
                                         &dbus_glib_p0_object_info);
}

static void
p0_dbus_service_init (P0DBusService *service)
{
}


static void
p0_dbus_service_set_active (P0DBusService *service,
                            gboolean       active)
{
        if (service->active != active) {
                service->active = active;

                g_signal_emit (service,
                               p0_dbus_service_signals[ACTIVE_CHANGED], 0,
                               active);
        }
}

P0DBusService *
p0_dbus_service_new (void)
{
        return g_object_new (TYPE_P0_DBUS_SERVICE, NULL);
}

gboolean
p0_dbus_service_get_active (P0DBusService  *service,
                            gboolean       *active,
                            GError        **dbus_error)
{
        g_return_val_if_fail (IS_P0_DBUS_SERVICE (service), FALSE);
        g_return_val_if_fail (active != NULL, FALSE);

        *active = service->active;

        return TRUE;
}

// FIXME: this should actually be connected to the mute state
//        of the amplifier, not directly to the play-state of
//        of the alsa object
void
p0_dbus_service_notify_playstate (P0DBusService *service,
                                  PlayState      new_state)
{
        g_return_if_fail (IS_P0_DBUS_SERVICE (service));

        p0_dbus_service_set_active (service, new_state == PLAYING);
}
