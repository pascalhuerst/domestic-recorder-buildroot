#ifndef __P0_INPUT_H__
#define __P0_INPUT_H__


#define TYPE_P0_INPUT            (p0_input_get_type ())
#define P0_INPUT(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_P0_INPUT, P0Input))
#define P0_INPUT_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_P0_INPUT, P0InputClass))
#define IS_P0_INPUT(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_P0_INPUT))
#define IS_P0_INPUT_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_P0_INPUT))
#define P0_INPUT_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_P0_INPUT, P0InputClass))



typedef struct _P0InputClass P0InputClass;

struct _P0InputClass
{
        GObjectClass parent_class;

        /*  signals  */
        void (* turn) (P0Input *input,
                       gint     amount);
};


GType       p0_input_get_type   (void) G_GNUC_CONST;

P0Input   * p0_input_new        (const gchar *device);


#endif  /*  __P0_INPUT_H__  */

