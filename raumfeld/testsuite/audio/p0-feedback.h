#ifndef __P0_FEEDBACK_H__
#define __P0_FEEDBACK_H__


#define TYPE_P0_FEEDBACK            (p0_feedback_get_type ())
#define P0_FEEDBACK(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_P0_FEEDBACK, P0Feedback))
#define P0_FEEDBACK_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_P0_FEEDBACK, P0FeedbackClass))
#define IS_P0_FEEDBACK(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_P0_FEEDBACK))
#define IS_P0_FEEDBACK_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_P0_FEEDBACK))
#define P0_FEEDBACK_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_P0_FEEDBACK, P0FeedbackClass))


typedef struct _P0FeedbackClass P0FeedbackClass;

struct _P0FeedbackClass
{
        GObjectClass parent_class;
};


GType        p0_feedback_get_type    (void) G_GNUC_CONST;

P0Feedback * p0_feedback_new         (void);

void         p0_feedback_subscribe   (P0Feedback  *feedback,
                                      const gchar *client_ip,
                                      gint         client_port,
                                      gint         timeout);
void         p0_feedback_unsubscribe (P0Feedback  *feedback,
                                      const gchar *client_ip,
                                      gint         client_port);

void         p0_feedback_set_levels  (P0Feedback  *feedback,
                                      gint16       playback_level_l,
                                      gint16       playback_level_r,
                                      gint16       capture_level_l,
                                      gint16       capture_level_r);



#endif  /*  __P0_FEEDBACK_H__  */
