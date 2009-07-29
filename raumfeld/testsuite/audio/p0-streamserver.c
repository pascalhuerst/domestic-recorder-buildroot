#include <glib.h>
#include <glib-object.h>
#include "p0-streamserver.h"
#include <libsoup/soup.h>
#include <memory.h>
#include <stdio.h>
#include <stdlib.h>

#define BUFFERSIZE (1024 * 1024 * 2)
#define BUFFERMASK (BUFFERSIZE - 1)
#define MAX_NUM_BYTES_PENDING 1024 * 1024 * 2

typedef struct
{
  SoupMessage *msg;
  int bytesPending;
  gboolean eos;
} Message;

typedef struct
{
  int port;
  int maxChunkLen;
  gchar *contentType;
  gint idleScheduled;

  gboolean eos;
  SoupServer *server;
  GMainContext *context;
  GMainLoop *loop;
  GList *messages;
  SoupSession *session;
  gchar *user_agent;
  char *buffer;
  int writePos;
  int readPos;
} P0StreamServerPrivate;

enum
{
  PROP_0,
  PROP_SERVER_PORT,
  PROP_MAX_CHUNK_LEN,
  PROP_CONTENT_TYPE
};

extern const char *myAdress;

#define P0_STREAMSERVER_GET_PRIVATE(obj) G_TYPE_INSTANCE_GET_PRIVATE ((obj), P0_TYPE_STREAMSERVER, P0StreamServerPrivate)
#define parent_class p0_streamserver_parent_class

static GObject *p0_streamserver_constructor (GType type, guint n_params, GObjectConstructParam *params);
static void p0_streamserver_finalize     (GObject *object);
static void p0_streamserver_get_property(GObject *object, guint property_id, GValue *value, GParamSpec *pspec);
static void p0_streamserver_set_property (GObject *object, guint property_id, const GValue *value, GParamSpec *pspec);
static void p0_streamserver_server_callback(SoupServer *soup_server,
					    SoupMessage *msg,
					    const char *path,
					    GHashTable *query,
					    SoupClientContext *context,
					    P0StreamServer *pThis);

static gboolean p0_streamserver_on_idle(P0StreamServer *pThis);

G_DEFINE_TYPE (P0StreamServer, p0_streamserver, G_TYPE_OBJECT);

static void p0_streamserver_class_init (P0StreamServerClass *klass)
{
  GObjectClass *object_class = G_OBJECT_CLASS (klass);
  object_class->constructor = p0_streamserver_constructor;
  object_class->finalize     = p0_streamserver_finalize;
  object_class->get_property = p0_streamserver_get_property;
  object_class->set_property = p0_streamserver_set_property;

  g_object_class_install_property(object_class, PROP_SERVER_PORT,
      g_param_spec_int("server-port", NULL, NULL, -1, 65536, 80, G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY));

  g_object_class_install_property(object_class, PROP_MAX_CHUNK_LEN,
        g_param_spec_int("max-chunk-len", NULL, NULL, 0, 1024 * 1024, 1024 * 8, G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY));

  g_object_class_install_property(object_class, PROP_CONTENT_TYPE,
        g_param_spec_string("content-type", NULL, NULL, "application/octet-stream", G_PARAM_READWRITE | G_PARAM_CONSTRUCT_ONLY));

  g_type_class_add_private (object_class, sizeof (P0StreamServerPrivate));
}

static GObject *p0_streamserver_constructor(GType type,
                                            guint n_params,
                                            GObjectConstructParam *params)
{
        GObject *object = G_OBJECT_CLASS (parent_class)->constructor(type,
                                                                     n_params,
                                                                     params);
        P0StreamServer *pThis = P0_STREAMSERVER(object);
        P0StreamServerPrivate *priv = P0_STREAMSERVER_GET_PRIVATE (pThis);

        if (priv->port == -1)
        {
                priv->port = 49170;
        }

        int numTrys = 1000;
        do
        {
                priv->server = soup_server_new(SOUP_SERVER_PORT,
                                               priv->port,
                                               NULL);
        } while (!priv->server && numTrys-- && priv->port++);

        if (priv->server)
        {

                soup_server_add_handler(priv->server,
                                        NULL,
                                        (SoupServerCallback) p0_streamserver_server_callback,
                                        pThis,
                                        NULL);
                soup_server_run_async(priv->server);
                g_print("started server on port %d\n",
                        priv->port);
        } else
        {
                g_print("could not start the http server\n");
        }

        return object;
}

static Message *p0_streamserver_find_message(P0StreamServer *pThis,
                                             SoupMessage *msg)
{
        P0StreamServerPrivate *priv = P0_STREAMSERVER_GET_PRIVATE (pThis);
        GList *it = priv->messages;

        while (it)
        {
                Message *pMsg = it->data;

                if (pMsg->msg == msg)
                {
                        return pMsg;
                }

                it = g_list_next(it);
        }
        return NULL;
}

static void p0_streamserver_close_message(P0StreamServer *pThis,
                                          Message *pMsg)
{
        if (!pMsg->eos)
        {
                P0StreamServerPrivate *priv = P0_STREAMSERVER_GET_PRIVATE (pThis);

                soup_message_body_complete(pMsg->msg->response_body);
                soup_server_unpause_message(priv->server,
                                            pMsg->msg);
                pMsg->eos = TRUE;

                g_print("SServer: message 0x%08X is eos\n",
                        (unsigned int) pMsg->msg);
        }
}

static void p0_streamserver_message_finished(SoupMessage *msg,
                                             P0StreamServer *pThis)
{
        g_print("SServer: msg 0x%08X finished\n",
                (unsigned int) msg);

        P0StreamServerPrivate *priv = P0_STREAMSERVER_GET_PRIVATE (pThis);

        Message *pMsg = p0_streamserver_find_message(pThis,
                                                     msg);
        g_assert(pMsg);

        if (pMsg)
        {
                priv->messages = g_list_remove(priv->messages,
                                               pMsg);
                g_object_unref(pMsg->msg);
                g_free(pMsg);
        }
}

static void p0_streamserver_get_property(GObject *object,
                                         guint property_id,
                                         GValue *value,
                                         GParamSpec *pspec)
{
        P0StreamServerPrivate *priv = P0_STREAMSERVER_GET_PRIVATE (object);

        switch (property_id)
        {
        case PROP_SERVER_PORT:
                g_value_set_int(value,
                                soup_server_get_port(priv->server));
                break;

        case PROP_MAX_CHUNK_LEN:
                g_value_set_int(value,
                                priv->maxChunkLen);
                break;

        case PROP_CONTENT_TYPE:
                g_value_set_string(value,
                                   priv->contentType);
                break;
        }
}

static void p0_streamserver_set_property(GObject *object,
                                         guint property_id,
                                         const GValue *value,
                                         GParamSpec *pspec)
{
        P0StreamServerPrivate *priv = P0_STREAMSERVER_GET_PRIVATE (object);

        switch (property_id)
        {
        case PROP_SERVER_PORT:
                priv->port = g_value_get_int(value);
                break;

        case PROP_MAX_CHUNK_LEN:
                priv->maxChunkLen = g_value_get_int(value);
                break;

        case PROP_CONTENT_TYPE:
                g_free(priv->contentType);
                priv->contentType = g_strdup(g_value_get_string(value));
                break;
        }
}

static void p0_streamserver_wrote_data(SoupMessage *msg,
                                       SoupBuffer *chunk,
                                       P0StreamServer *pThis)
{
        Message *pMsg = p0_streamserver_find_message(pThis,
                                                     msg);
        g_assert(pMsg);

        if (pMsg)
        {
                pMsg->bytesPending -= chunk->length;
                g_assert(pMsg->bytesPending >= 0);
        }
}

static void p0_streamserver_server_callback(SoupServer *soup_server,
                                            SoupMessage *msg,
                                            const char *path,
                                            GHashTable *query,
                                            SoupClientContext *context,
                                            P0StreamServer *pThis)
{
        g_print("SServer: 0x%08X server callback, somebody wants to stream\n",
                (unsigned int) msg);

        P0StreamServerPrivate *priv = P0_STREAMSERVER_GET_PRIVATE (pThis);

        g_assert(soup_server == priv->server);

        Message *pMsg = g_new0(Message, 1);
        pMsg->msg = msg;
        pMsg->bytesPending = 0;
        pMsg->eos = FALSE;

        priv->messages = g_list_append(priv->messages,
                                       pMsg);

        soup_message_body_set_accumulate(msg->response_body,
                                         FALSE);
        g_signal_connect_object(msg,
                                "finished",
                                G_CALLBACK(p0_streamserver_message_finished),
                                pThis,
                                0);
        g_signal_connect_object(msg,
                                "wrote-body-data",
                                G_CALLBACK(p0_streamserver_wrote_data),
                                pThis,
                                0);

        soup_message_headers_append(msg->response_headers,
                                    "SERVER",
                                    "Raumfeld Renderer");
        soup_message_headers_append(msg->response_headers,
                                    "Connection",
                                    "close");
        soup_message_headers_append(msg->response_headers,
                                    "Content-Type",
                                    priv->contentType);

        soup_message_headers_set_encoding(msg->response_headers,
                                          SOUP_ENCODING_CHUNKED);
        soup_message_set_status_full(msg,
                                     200,
                                     "OK");

        g_object_ref(msg);
}

static void p0_streamserver_init(P0StreamServer *pThis)
{
        P0StreamServerPrivate *priv = P0_STREAMSERVER_GET_PRIVATE (pThis);
        priv->buffer = (char*) malloc(BUFFERSIZE);
}

static void p0_streamserver_finalize(GObject *pThis)
{
        P0StreamServerPrivate *priv = P0_STREAMSERVER_GET_PRIVATE (pThis);
        p0_streamserver_eos(P0_STREAMSERVER(pThis));
        g_free(priv->buffer);
        g_free(priv->contentType);
        G_OBJECT_CLASS (p0_streamserver_parent_class)->finalize(pThis);
}

void p0_streamserver_eos(P0StreamServer *pThis)
{
        P0StreamServerPrivate *priv = P0_STREAMSERVER_GET_PRIVATE (pThis);
        priv->eos = TRUE;

        if (g_atomic_int_compare_and_exchange(&priv->idleScheduled,
                                              0,
                                              1))
        {
                g_idle_add((GSourceFunc) p0_streamserver_on_idle,
                           pThis);
        }
}

static gboolean p0_streamserver_on_idle(P0StreamServer *pThis)
{
        P0StreamServerPrivate *priv = P0_STREAMSERVER_GET_PRIVATE (pThis);

        g_atomic_int_set(&priv->idleScheduled, 0);

        // close connections that take the data to slow
        GList *it = priv->messages;
        while (it)
        {
                Message *msg = it->data;

                if (!msg->eos && msg->bytesPending > MAX_NUM_BYTES_PENDING)
                {
                        p0_streamserver_close_message(pThis,
                                                      msg);
                        g_print("had to close message 0x%08X because data was received much to slow",
                                (unsigned int) msg->msg);
                }

                it = g_list_next(it);
        }

        while (priv->readPos < priv->writePos)
        {
                int todo = priv->writePos - priv->readPos;

                while (todo)
                {
                        int r = priv->readPos & BUFFERMASK;
                        int forNow = MIN(BUFFERSIZE - r, todo);

                        it = priv->messages;
                        while (it)
                        {
                                Message *msg = it->data;
                                if (!msg->eos)
                                {
                                        g_print("SServer: writing %d bytes (%d ... %d) to message 0x%08X\n",
                                                forNow,
                                                priv->readPos,
                                                priv->readPos + forNow,
                                                (unsigned int) msg->msg);

                                        msg->bytesPending += forNow;
                                        soup_message_body_append(msg->msg->response_body,
                                                                 SOUP_MEMORY_COPY,
                                                                 &priv->buffer[r],
                                                                 forNow);
                                        soup_server_unpause_message(priv->server,
                                                                    msg->msg);
                                }
                                it = g_list_next(it);
                        }

                        priv->readPos += forNow;
                        todo -= forNow;
                }
        }

        if (priv->eos)
        {
                priv->eos = FALSE;
                priv->readPos = priv->writePos = 0;

                GList *it = priv->messages;
                while (it)
                {
                        p0_streamserver_close_message(pThis,
                                                      it->data);
                        it = g_list_next(it);
                }

                memset(priv->buffer,
                       0xFFFFFFFF,
                       BUFFERSIZE);
        }

        return FALSE;
}

void p0_streamserver_eat(P0StreamServer *pThis,
                         const gchar *data,
                         int numBytes)
{
        P0StreamServerPrivate *priv = P0_STREAMSERVER_GET_PRIVATE (pThis);

        priv->eos = FALSE;

        if (priv->messages)
        {
                int todo = numBytes;

                while (todo)
                {
                        int w = priv->writePos & BUFFERMASK;
                        int forNow = MIN(BUFFERSIZE - w, todo);

                        memcpy(&priv->buffer[w],
                               &data[numBytes - todo],
                               forNow);

                        priv->writePos += forNow;
                        todo -= forNow;
                }

                if ((priv->writePos - priv->readPos) >= priv->maxChunkLen)
                {
                        if (g_atomic_int_compare_and_exchange(&priv->idleScheduled,
                                                              0,
                                                              1))
                        {
                                g_idle_add((GSourceFunc) p0_streamserver_on_idle,
                                           pThis);
                        }
                }
        }
}

int p0_streamserver_get_port(P0StreamServer *pThis)
{
        P0StreamServerPrivate *priv = P0_STREAMSERVER_GET_PRIVATE (pThis);
        return soup_server_get_port(priv->server);
}

P0StreamServer *
p0_streamserver_new(int port,
                    int maxChunkLen,
                    const char *contentType)
{
        return g_object_new(P0_TYPE_STREAMSERVER,
                            "server-port",
                            port,
                            "max-chunk-len",
                            maxChunkLen,
                            "content-type",
                            contentType,
                            NULL);
}
