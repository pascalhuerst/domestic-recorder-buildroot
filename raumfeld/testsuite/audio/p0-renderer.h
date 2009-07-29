#ifndef __P0_RENDERER_H__
#define __P0_RENDERER_H__


#define TYPE_P0_RENDERER            (p0_renderer_get_type ())
#define P0_RENDERER(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_P0_RENDERER, P0Renderer))
#define P0_RENDERER_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_P0_RENDERER, P0RendererClass))
#define IS_P0_RENDERER(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_P0_RENDERER))
#define IS_P0_RENDERER_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_P0_RENDERER))
#define P0_RENDERER_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_P0_RENDERER, P0RendererClass))

typedef struct _P0RendererClass P0RendererClass;

struct _P0RendererClass
{
        GObjectClass parent_class;
};


GType         p0_renderer_get_type               (void) G_GNUC_CONST;

P0Renderer  * p0_renderer_new                    (GUPnPContext *context,
                                                  const gchar  *udn,
                                                  const gchar  *time_service,
                                                  P0Feedback   *feedback);
void          p0_renderer_run                    (P0Renderer   *renderer);

P0Transport * p0_renderer_get_av_transport       (P0Renderer   *renderer);
P0Control   * p0_renderer_get_rendering_control  (P0Renderer   *renderer);
P0Manager   * p0_renderer_get_connection_manager (P0Renderer   *renderer);


#endif  /*  __P0_RENDERER_H__  */
