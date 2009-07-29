#ifndef __P0_CONTROL_H__
#define __P0_CONTROL_H__


#define TYPE_P0_CONTROL            (p0_control_get_type ())
#define P0_CONTROL(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_P0_CONTROL, P0Control))
#define P0_CONTROL_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_P0_CONTROL, P0ControlClass))
#define IS_P0_CONTROL(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_P0_CONTROL))
#define IS_P0_CONTROL_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_P0_CONTROL))
#define P0_CONTROL_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_P0_CONTROL, P0ControlClass))


typedef struct _P0ControlClass P0ControlClass;

struct _P0ControlClass
{
        GObjectClass parent_class;
};


GType       p0_control_get_type  (void) G_GNUC_CONST;

P0Control * p0_control_new       (GUPnPDevice *device);
void        p0_control_set_mixer (P0Control   *control,
                                  P0Mixer     *mixer);
void        p0_control_set_alsa  (P0Control   *control,
                                  P0Alsa      *alsa);

void        p0_control_set_out_stream_adress (P0Control  *control,
                                              const char *ip,
                                              int         port);

#endif  /*  __P0_CONTROL_H__  */
