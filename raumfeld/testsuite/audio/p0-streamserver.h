#ifndef P0STREAMSERVER_H_
#define P0STREAMSERVER_H_


#define P0_TYPE_STREAMSERVER            (p0_streamserver_get_type ())
#define P0_STREAMSERVER(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), P0_TYPE_STREAMSERVER, P0StreamServer))
#define P0_STREAMSERVER_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), P0_TYPE_STREAMSERVER, P0StreamServerClass))
#define P0_IS_STREAMSERVER(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), P0_TYPE_STREAMSERVER))
#define P0_IS_STREAMSERVER_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), P0_TYPE_STREAMSERVER))
#define P0_STREAMSERVER_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj), P0_TYPE_STREAMSERVER, P0StreamServerClass))

typedef struct _P0StreamServerClass P0StreamServerClass;

struct _P0StreamServerClass
{
  GObjectClass  parent_class;
};

struct _P0StreamServer
{
  GObject       parent_instance;
};


typedef struct _P0StreamServer P0StreamServer;

GType            p0_streamserver_get_type  (void) G_GNUC_CONST;

/* will open a http server on port "port" with the given "contentType". After each "maxChunkLen" bytes eaten, the stuff will
 * be sent out to the listening messages */
P0StreamServer * p0_streamserver_new       (int port, int maxChunkLen, const char *contentType);

void p0_streamserver_eos(P0StreamServer *pThis);
void p0_streamserver_eat(P0StreamServer *pThis, const char *data, int numBytes);
int p0_streamserver_get_port(P0StreamServer *pThis);


#endif /*P0STREAMSERVER_H_*/
