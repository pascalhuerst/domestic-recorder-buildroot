#ifndef __P0_TRANSPORT_H__
#define __P0_TRANSPORT_H__


#define TYPE_P0_TRANSPORT            (p0_transport_get_type ())
#define P0_TRANSPORT(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_P0_TRANSPORT, P0Transport))
#define P0_TRANSPORT_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_P0_TRANSPORT, P0TransportClass))
#define IS_P0_TRANSPORT(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_P0_TRANSPORT))
#define IS_P0_TRANSPORT_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_P0_TRANSPORT))
#define P0_TRANSPORT_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_P0_TRANSPORT, P0TransportClass))


typedef struct _P0TransportClass P0TransportClass;

struct _P0TransportClass
{
        GObjectClass parent_class;

        /*  signals  */
        void (* set_uri_called) (P0Transport *transport,
                                 const gchar *uri);
        void (* play_called)    (P0Transport *transport);
        void (* stop_called)    (P0Transport *transport);
        void (* trigger_set)    (P0Transport *transport,
                                 const gchar *trigger_time);
};


GType         p0_transport_get_type             (void) G_GNUC_CONST;

P0Transport * p0_transport_new                  (GUPnPDevice    *device,
                                                 const gchar    *time_service);

void          p0_transport_notify_playstate     (P0Transport    *transport,
                                                 PlayState       new_state);
void          p0_transport_notify_buffer_filled (P0Transport    *transport);


#endif  /*  __P0_TRANSPORT_H__  */
