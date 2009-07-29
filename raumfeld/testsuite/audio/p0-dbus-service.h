#ifndef __P0_DBUS_SERVICE_H__
#define __P0_DBUS_SERVICE_H__


#define P0_DBUS_SERVICE_NAME  "com.raumfeld.Renderer"
#define P0_DBUS_SERVICE_PATH  "/com/raumfeld/Renderer"


#define TYPE_P0_DBUS_SERVICE            (p0_dbus_service_get_type ())
#define P0_DBUS_SERVICE(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_P0_DBUS_SERVICE, P0DBusService))
#define P0_DBUS_SERVICE_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_P0_DBUS_SERVICE, P0DBusServiceClass))
#define IS_P0_DBUS_SERVICE(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_P0_DBUS_SERVICE))
#define IS_P0_DBUS_SERVICE_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_P0_DBUS_SERVICE))
#define P0_DBUS_SERVICE_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_P0_DBUS_SERVICE, P0DBusServiceClass))



typedef struct _P0DBusServiceClass P0DBusServiceClass;

struct _P0DBusServiceClass
{
        GObjectClass parent_class;
};


GType           p0_dbus_service_get_type         (void) G_GNUC_CONST;

P0DBusService * p0_dbus_service_new              (void);

gboolean        p0_dbus_service_get_active       (P0DBusService  *service,
                                                  gboolean       *active,
                                                  GError        **dbus_error);

void            p0_dbus_service_notify_playstate (P0DBusService  *service,
                                                  PlayState       new_state);


#endif  /*  __P0_DBUS_SERVICE_H__  */

