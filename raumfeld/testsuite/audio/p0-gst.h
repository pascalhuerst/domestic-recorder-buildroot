#ifndef __P0_GST_H__
#define __P0_GST_H__


#define TYPE_P0_GST            (p0_gst_get_type ())
#define P0_GST(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_P0_GST, P0Gst))
#define P0_GST_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_P0_GST, P0GstClass))
#define IS_P0_GST(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_P0_GST))
#define IS_P0_GST_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_P0_GST))
#define P0_GST_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_P0_GST, P0GstClass))

typedef struct _P0GstClass P0GstClass;

struct _P0GstClass
{
        GObjectClass parent_class;

        /*  signals  */
        void (* stream_error) (P0Gst        *gst);
        void (* tag_found)    (P0Gst        *gst,
                               const gchar  *tag,
                               const GValue *value);
};


GType       p0_gst_get_type         (void) G_GNUC_CONST;

P0Gst     * p0_gst_new              (void);

void        p0_gst_set_alsa_ptr     (P0Gst       *gst_object,
                                     P0Alsa      *alsa_object);

void        p0_gst_start_streaming  (P0Gst       *gst_object,
                                     const gchar *uri);


void        p0_gst_stop_streaming   (P0Gst       *gst_object);

void        p0_gst_notify_playstate (P0Gst       *gst_object,
                                     PlayState    new_state);

void        p0_gst_notify_error     (P0Gst       *gst_object,
                                     const gchar *error_string);


gchar     * p0_gst_get_supported_protocols_string (void);

void        p0_gst_set_stream_start_time (P0Gst       *gst,
                                          const gchar *stream_start_time);

int p0_gst_get_out_stream_port(P0Gst *gst);


#endif  /*  __P0_GST_H__  */

