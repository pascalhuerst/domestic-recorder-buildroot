#ifndef __P0_MANAGER_H__
#define __P0_MANAGER_H__


#define TYPE_P0_MANAGER            (p0_manager_get_type ())
#define P0_MANAGER(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_P0_MANAGER, P0Manager))
#define P0_MANAGER_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_P0_MANAGER, P0ManagerClass))
#define IS_P0_MANAGER(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_P0_MANAGER))
#define IS_P0_MANAGER_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_P0_MANAGER))
#define P0_MANAGER_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_P0_MANAGER, P0ManagerClass))


typedef struct _P0ManagerClass P0ManagerClass;

struct _P0ManagerClass
{
        GObjectClass parent_class;

        /*  signals  */
};


GType       p0_manager_get_type (void) G_GNUC_CONST;

P0Manager * p0_manager_new      (GUPnPDevice *device);


#endif  /*  __P0_MANAGER_H__  */
