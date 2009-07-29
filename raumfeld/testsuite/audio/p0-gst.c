/*
 * P0Gst:
 *
 * This class serves the GStreamer used for streaming (get) and decoding
 */

#include <string.h>
#include <gio/gio.h>
#include <gst/gst.h>
#include <raumfeld/time.h>

#include "p0-renderer-types.h"
#include "p0-alsa.h"
#include "p0-gst.h"
#include "p0-marshal.h"
#include "options.h"
#include "p0-streamserver.h"

//#define STREAMDEBUG
#define GSTDEBUG
//#define NOSTREAMSERVER

struct _P0Gst
{
        GObject           parent_instance;
        P0Alsa           *alsa_object;

        GstElement       *pipeline;
        GstElement       *httpsource;
        GstElement       *decodebin;
        GstElement       *sink;
        GstElement       *capsfilter;
        GstElement       *audioconv;
#ifdef STREAMDEBUG
        GstElement       *identity;
        gint64            sample_pos;
        gint64            stream_byte_pos;
        gint64            old_stream_byte_pos;
#endif

        gint64            seek_pos_samples;

        int               is_seeking;
        int               do_seek;

  		P0StreamServer *stream_server;

};


/* Signals for communication with the rest of the world */
enum
{
        STREAM_ERROR,
        TAG_FOUND,
        LAST_SIGNAL
};



static void     p0_gst_cb_new_pad       (GstElement *element, GstPad *pad, P0Gst* gst_object);
static void     p0_gst_cb_handoff       (GstElement *fakesrc, GstBuffer *buffer,GstPad *pad,P0Gst *gst_object);
static gboolean p0_gst_bus_callback     (GstBus *bus, GstMessage *msg, gpointer gst_object);
static void     p0_gst_dispose          (GObject *object);
static void     p0_gst_handle_error     (P0Gst *gst, const gchar *error_string);
static void     p0_gst_handle_tags      (P0Gst *gst, const GstTagList *list);
static gboolean p0_gst_emit_error       (P0Gst *gst);
//static void     p0_gst_remove_pipeline  (P0Gst *gst);
static void     p0_gst_build_pipeline   (P0Gst *gst);



G_DEFINE_TYPE   (P0Gst, p0_gst, G_TYPE_OBJECT)

static guint p0_gst_signals[LAST_SIGNAL] = { 0 };




static void
p0_gst_class_init (P0GstClass *klass)
{
        GObjectClass *object_class = G_OBJECT_CLASS (klass);

        p0_gst_signals[STREAM_ERROR] =
                g_signal_new ("stream-error",
                              G_TYPE_FROM_CLASS (klass),
                              G_SIGNAL_RUN_FIRST,
                              G_STRUCT_OFFSET (P0GstClass, stream_error),
                              NULL, NULL,
                              g_cclosure_marshal_VOID__VOID,
                              G_TYPE_NONE, 0);

        p0_gst_signals[TAG_FOUND] =
                g_signal_new ("tag-found",
                              G_TYPE_FROM_CLASS (klass),
                              G_SIGNAL_RUN_FIRST | G_SIGNAL_DETAILED,
                              G_STRUCT_OFFSET (P0GstClass, tag_found),
                              NULL, NULL,
                              p0_marshal_VOID__STRING_BOXED,
                              G_TYPE_NONE, 2, G_TYPE_STRING, G_TYPE_VALUE);

        object_class->dispose = p0_gst_dispose;
}

P0Gst*
p0_gst_new (void)
{
        return g_object_new (TYPE_P0_GST, NULL);
}

static void
p0_gst_build_pipeline(P0Gst *gst_object)
{
        GstBus *bus;

        g_print("->Gst: building pipeline\n");

        /* create & connect  all needed g-streamer parts for this stream */

        gst_object->pipeline = gst_pipeline_new ("p0-pipeline");

        gst_object->httpsource = gst_element_factory_make ("souphttpsrc", "httpsource");

        if(!gst_object->httpsource) {
                g_error("failed to create element souphttpsrc");
                return;
        }

 #ifdef STREAM_DEBUG
        gst_object->identity = gst_element_factory_make ("identity", "identity");

        if(!gst_object->identity) {
                g_error("failed to create element identitiy");
                return;
        }
#endif


        gst_object->decodebin  = gst_element_factory_make ("decodebin",  "decoder");

        if(!gst_object->decodebin) {
                g_error("failed to create element decodebin");
                return;
        }

        gst_object->audioconv = gst_element_factory_make ("audioconvert",  "audioconvert");

        if (!gst_object->audioconv) {
                g_error("failed to create element audioconv");
                return;
        }

        gst_object->capsfilter = gst_element_factory_make ("capsfilter",  "capsfilter");

        if (!gst_object->capsfilter) {
                g_error("failed to create element capsfilter");
                return;
        }


        gst_object->sink = gst_element_factory_make ("fakesink",  "sink");

        if (!gst_object->sink) {
                g_error("failed to create element fakesink");
                return;
        }

        /* Limit to 16 Bit 44100 kHz before connecting pads
         *  so the audioconverter can work as we want*/
        g_object_set (G_OBJECT (gst_object->capsfilter), "caps",
                      gst_caps_new_simple ("audio/x-raw-int",
                                           "endianness", G_TYPE_INT, G_BYTE_ORDER,
                                           "signed", G_TYPE_BOOLEAN,TRUE,
                                           "width", G_TYPE_INT, 16,
                                           "depth", G_TYPE_INT, 16,
                                           "rate", G_TYPE_INT, 44100,
                                           "channels", G_TYPE_INT, 2,
                                           NULL), NULL);


        /* add and connect pads */
        gst_bin_add_many (GST_BIN (gst_object->pipeline),
                          gst_object->httpsource,
#ifdef STREAM_DEBUG
                          gst_object->identity,
#endif
                          gst_object->decodebin,
                          gst_object->audioconv,
                          gst_object->capsfilter,
                          gst_object->sink, NULL);


        if(!gst_element_link_many (gst_object->httpsource,
#ifdef STREAM_DEBUG
                                   gst_object->identity,
#endif
                                   gst_object->decodebin,
                                   NULL)) {

                g_error("failed to link pads to decodebin!\n");

                return;
        }

        if(!gst_element_link_many (gst_object->audioconv,
                                   gst_object->capsfilter,
                                   gst_object->sink,
                                   NULL)) {

                g_error("failed to link pads from audioconv!\n");

                return;
        }

        /* listen for newly created pads */
        g_signal_connect (gst_object->decodebin,
                          "pad-added",
                          G_CALLBACK (p0_gst_cb_new_pad),
                          gst_object);


        /* setup fake source */
        g_object_set (G_OBJECT (gst_object->sink),
                      "signal-handoffs", TRUE,
                      NULL);

        /* callback for audio data */
        g_signal_connect (gst_object->sink, "handoff",
                          G_CALLBACK (p0_gst_cb_handoff),
                          gst_object);

        /* setup bus message callback for interesting tjhings like metadata & co */
        bus = gst_pipeline_get_bus (GST_PIPELINE (gst_object->pipeline));

        gst_bus_add_watch ( bus,
                            p0_gst_bus_callback,
                            gst_object);

        gst_object_unref (bus);

        /* init done */
}

#if 0
static void
p0_gst_remove_pipeline(P0Gst *gst_object)
{
        g_print("->Gst: removing pipeline\n");

        if(gst_object->httpsource)
          gst_bin_remove(GST_BIN(gst_object->pipeline),gst_object->httpsource);

        gst_object->httpsource = NULL;

        if(gst_object->decodebin)
          gst_bin_remove(GST_BIN(gst_object->pipeline),gst_object->decodebin);

        gst_object->decodebin = NULL;

        if(gst_object->audioconv)
          gst_bin_remove(GST_BIN(gst_object->pipeline),gst_object->audioconv);

        gst_object->audioconv = NULL;

        if(gst_object->capsfilter)
          gst_bin_remove(GST_BIN(gst_object->pipeline),gst_object->capsfilter);

        gst_object->capsfilter = NULL;

        if(gst_object->sink)
          gst_bin_remove(GST_BIN(gst_object->pipeline),gst_object->sink);

        gst_object->sink = NULL;


        if(gst_object->pipeline)
          gst_object_unref(gst_object->pipeline);

        gst_object->pipeline = NULL;
}
#endif


static void
p0_gst_init (P0Gst *gst_object)
{
#ifdef GSTDEBUG
   gst_debug_set_default_threshold(GST_LEVEL_WARNING);
#endif

  p0_gst_build_pipeline(gst_object);

#ifndef NOSTREAMSERVER
  gst_object->stream_server = p0_streamserver_new(options_get_server_port(), 8192 * 4, "application/octet-stream");
#else
  gst_object->stream_server = NULL;
#endif
}

static void
p0_gst_dispose (GObject *object)
{
  P0Gst *gst_object = (P0Gst*)object;

  // FIXME: Stop here

  if(gst_object->stream_server)
    g_object_unref(gst_object->stream_server);

  gst_object->stream_server = NULL;

  G_OBJECT_CLASS (p0_gst_parent_class)->dispose (object);
}

void
p0_gst_set_alsa_ptr (P0Gst *gst_object, P0Alsa * alsa_object)
{

        gst_object->alsa_object = alsa_object;
}



static void
p0_gst_cb_new_pad (GstElement *element,
                   GstPad     *pad,
                   P0Gst      *gst_object)
{
        gchar *name;
        GstPad *sinkpad;

        g_return_if_fail (IS_P0_GST (gst_object));

        sinkpad = gst_element_get_static_pad (gst_object->audioconv, "sink");

        name = gst_pad_get_name (pad);

        g_print ("->GST: a new pad %s was created\n", name);

        g_free (name);

        if(gst_pad_link (pad, sinkpad)!=GST_PAD_LINK_OK)
                g_printerr("!!->GST_ERROR: failed to link pads!\n");

        gst_object_unref (sinkpad);
}

static gboolean
p0_gst_emit_error (P0Gst *gst)
{
    g_signal_emit (gst, p0_gst_signals[STREAM_ERROR], 0);

    return FALSE;
}

static void
p0_gst_handle_error (P0Gst       *gst_object,
                     const gchar *errorstring)
{
    GSource  *source;
    GClosure *closure;

    g_print("\n!!Gst Error: %s\n", errorstring);

    p0_gst_stop_streaming (gst_object);

    source = g_idle_source_new ();
    g_source_set_priority (source, G_PRIORITY_HIGH);
    closure = g_cclosure_new_object (G_CALLBACK (p0_gst_emit_error),
                                     G_OBJECT (gst_object));

    g_source_set_closure (source, closure);
    g_source_attach (source, NULL);
    g_source_unref (source);
}

typedef struct
{
    P0Gst  *gst;
    GQuark  tag;
    GValue  value;
} P0GstTagData;

static void
p0_gst_tag_data_free (P0GstTagData *data)
{
    g_value_unset (&data->value);
    g_slice_free (P0GstTagData, data);
}

static gboolean
p0_gst_emit_tag (P0GstTagData *data)
{
    g_signal_emit (data->gst, p0_gst_signals[TAG_FOUND],
                   data->tag, g_quark_to_string (data->tag), &data->value);

    return FALSE;
}

static void
p0_gst_handle_tag (const GstTagList *list,
                   const gchar      *tag,
                   P0Gst            *gst_object)
{
    P0GstTagData  data = { gst_object, 0, { 0, } };

    if (gst_tag_list_copy_value (&data.value, list, tag)) {
        GSource  *source;
        GClosure *closure;

        data.tag = g_quark_from_string (tag);

        closure = g_cclosure_new (G_CALLBACK (p0_gst_emit_tag),
                                  g_slice_dup (P0GstTagData, &data),
                                  (GClosureNotify) p0_gst_tag_data_free);
        g_object_watch_closure (G_OBJECT (gst_object), closure);

        source = g_idle_source_new ();
        g_source_set_closure (source, closure);
        g_source_attach (source, NULL);
        g_source_unref (source);
    }
}

static void
p0_gst_handle_tags (P0Gst            *gst_object,
                    const GstTagList *list)
{
  gst_tag_list_foreach (list,
                        (GstTagForeachFunc) p0_gst_handle_tag, gst_object);
}

static gboolean
p0_gst_bus_callback (GstBus     *bus,
                     GstMessage *msg,
                     gpointer    pointer)
{
        P0Gst *gst_object;

        g_return_val_if_fail (IS_P0_GST (pointer),FALSE);

        gst_object = pointer;

        switch (GST_MESSAGE_TYPE (msg)) {
        case GST_MESSAGE_EOS:

                g_print ("->GST Message: end of stream\n");

                /* notify alsa that the stream is going to end soon*/
                p0_alsa_notify_end_stream(gst_object->alsa_object);

                if(gst_object->stream_server)
                  p0_streamserver_eos(gst_object->stream_server);

                /* stop the stream */
                gst_element_set_state (gst_object->pipeline , GST_STATE_READY);
                break;

        case GST_MESSAGE_ERROR: {
                        GError *error = NULL;

                        gst_message_parse_error (msg, &error, NULL);
                        p0_gst_handle_error(gst_object, error->message);
                        g_error_free (error);
                }
                break;

        case GST_MESSAGE_TAG: {
                        GstTagList *taglist;

                        gst_message_parse_tag(msg,&taglist);
                        p0_gst_handle_tags(gst_object, taglist);
                        gst_tag_list_free(taglist);
                }
                break;

        case GST_MESSAGE_BUFFERING: {
                        gint p;

                        gst_message_parse_buffering(msg,&p);

                        g_print("->GST Message: Buffering: %d\n",p);
                }
                break;
        case GST_MESSAGE_ASYNC_DONE:
                g_print("->GST Message: %s\n",GST_MESSAGE_TYPE_NAME(msg));
                // todo filter other async messages
                gst_object->is_seeking = FALSE;
                break;
        default:
                break; //g_print("->GST Message: %s\n",GST_MESSAGE_TYPE_NAME(msg));break;
        }

        return TRUE;
}


void
p0_gst_start_streaming (P0Gst       *gst_object,
                        const gchar *uri)
{
        g_return_if_fail (IS_P0_GST (gst_object));
        g_return_if_fail (uri != NULL);

        g_print("->GST: start playback: \"%s\"\n", uri);

        g_object_set (gst_object->httpsource, "location", uri, NULL);

#ifdef STREAM_DEBUG
        gst_object->stream_byte_pos = 0;

        gst_object->old_stream_byte_pos = 0;

        gst_object->sample_pos = 0;
#endif

        p0_alsa_notify_stream_incoming(gst_object->alsa_object);


        GstStateChangeReturn val = gst_element_set_state (gst_object->pipeline,
                                   GST_STATE_PAUSED);


        GstState state, pending;

        g_print("->GST: trying to set pipeline to pause \n");

        gst_element_get_state(GST_ELEMENT(gst_object->pipeline), &state, &pending, GST_MSECOND * 6000);

        if(pending != GST_STATE_VOID_PENDING || state != GST_STATE_PAUSED) {
                p0_gst_handle_error(gst_object,
                                    "can't set pipeline to pause!! Aborting play process");
                return;
        }

        g_print("->GST: pipeline set to pause \n");

        //gst_object->seek_pos_samples = 44100*60;



        if( gst_object->seek_pos_samples && gst_object->do_seek ) {

                gst_object -> is_seeking = TRUE;
                gst_object-> do_seek = FALSE;

                gint64 nanos = (double) gst_object -> seek_pos_samples * (1000.0 * 1000.0 * 10.0 / 441);

                gboolean seeked =  gst_element_seek (GST_ELEMENT(gst_object->pipeline), 1.0, GST_FORMAT_TIME,
                                                     GST_SEEK_FLAG_FLUSH | GST_SEEK_FLAG_ACCURATE, GST_SEEK_TYPE_SET, nanos, GST_SEEK_TYPE_NONE, 0);

                if(seeked == FALSE) {
                        p0_gst_handle_error(gst_object,
                                            "can't seek!! Aborting play process");

                        return;
                } else
                        g_print("->GST: pipeline seeked \n");
        }



        val = gst_element_set_state (gst_object->pipeline,
                                     GST_STATE_PLAYING);


        gst_element_get_state(GST_ELEMENT(gst_object->pipeline), &state, &pending, GST_MSECOND * 6000);

        if(pending != GST_STATE_VOID_PENDING || state != GST_STATE_PLAYING) {

                p0_gst_handle_error(gst_object,
                                    "can't set pipeline to play!! Aborting play process\n");

                return;
        }

        switch(val) {
        case GST_STATE_CHANGE_FAILURE:
                g_print("!!->GST: gst_element_set_state returned failure\n");
                break;

        case GST_STATE_CHANGE_SUCCESS:
                g_print("->GST: gst_element_set_state returned success\n");
                break;

        case GST_STATE_CHANGE_ASYNC:
                g_print("->GST: gst_element_set_state returned async\n");
                break;

        case GST_STATE_CHANGE_NO_PREROLL:
                g_print("->GST: gst_element_set_state returned no preroll\n");
                break;

        default:
                g_print("->GST: gst_element_set_state returned unknown\n");
                break;
        }

        g_print("GST->newdecodebin consists of: ");

        GstIterator *elem_it = NULL;
        gboolean done = FALSE;

        elem_it = gst_bin_iterate_elements (GST_BIN (gst_object->decodebin));

        while (!done) {

                GstElement *element = NULL;

                switch (gst_iterator_next (elem_it, (gpointer) & element)) {
                case GST_ITERATOR_OK:

                        g_print("%s, ", gst_element_get_name(element));
                        gst_object_unref (element);
                        break;
                case GST_ITERATOR_RESYNC:
                        gst_iterator_resync (elem_it);
                        break;
                case GST_ITERATOR_ERROR:
                        done = TRUE;
                        break;
                case GST_ITERATOR_DONE:
                        done = TRUE;
                        break;
                }
        }
        gst_iterator_free (elem_it);

        g_print("\n");
}

void
p0_gst_stop_streaming (P0Gst *gst_object)
{
        g_return_if_fail (IS_P0_GST (gst_object));

        g_print("->GST: stop playbback \n");

        /* It's important to do this before we stop the pipeline! */
        p0_alsa_stop_stream(gst_object->alsa_object);

        if(gst_object->pipeline)
          gst_element_set_state (gst_object->pipeline , GST_STATE_READY);

        if(gst_object->stream_server)
          p0_streamserver_eos(gst_object->stream_server);

}

void
p0_gst_notify_error (P0Gst       *gst_object,
                     const gchar *error_string)
{
        g_print("->GST: notify error: stop streaming\n");

        if(gst_object->pipeline)
          gst_element_set_state (gst_object->pipeline , GST_STATE_READY);

        if(gst_object->stream_server)
          p0_streamserver_eos(gst_object->stream_server);
}

void
p0_gst_set_stream_start_time (P0Gst       *gst_object,
                              const gchar *start_time_string)
{
        struct timeval          start_time;
        struct timeval          punch_time;
        char                    trigger_time[255];

        g_return_if_fail (IS_P0_GST (gst_object));
        g_return_if_fail (start_time_string != NULL);

        /* FIXME: no buffer overflows please */

        g_print("->GST: original stream start was: %s\n",start_time_string);

        /* FIXME: no buffer overflows please */
        sscanf (start_time_string, "%li:%li", &start_time.tv_sec, &start_time.tv_usec);

        p0_alsa_get_punch_time(gst_object->alsa_object, &punch_time);

        g_print("->GST: punch time is %li:%li \n", punch_time.tv_sec, punch_time.tv_usec);

        sprintf(trigger_time, "%li:%li", punch_time.tv_sec, punch_time.tv_usec);

        p0_alsa_set_next_trigger_time(gst_object->alsa_object, trigger_time);

        long long int diff;

        diff = time_diff (&punch_time, &start_time);

        g_print("->GST: difference in uSec is:  %lld \n", diff);

        gst_object->seek_pos_samples = ((double) 44100/(1000 * 1000) * (double) diff);

        g_print("->GST: so the seek time in samples is %lld \n", gst_object->seek_pos_samples);

        gst_object->do_seek = TRUE;

}




static void
p0_gst_cb_handoff (GstElement *fakesrc,
                   GstBuffer  *buffer,
                   GstPad     *pad,
                   P0Gst      *gst_object)
{
        /* FIXME: check whether this is really the correct format */

#ifdef STREAMDEBUG

        GstFormat fmt = GST_FORMAT_BYTES;

        gint64 pos;

        gst_element_query_position (gst_object->httpsource, &fmt, &pos);

        gst_object->stream_byte_pos = pos;

        if(gst_object->sample_pos < 4096)
        {

          g_print("samplepos:%d lengths: %d httpbytepos:%d diffb %d                    \n",
                  (int) gst_object->sample_pos,
                  buffer->size/4,
                  (int) pos,
                  (int) (pos - gst_object->old_stream_byte_pos)
                 );


          if(buffer->timestamp!=GST_CLOCK_TIME_NONE) {
                  gint64 tpos;
                  gint64 tdur;

                  tpos = (double) GST_TIME_AS_NSECONDS(buffer->timestamp) /  (double) 22675.736961451;
                  tdur = (double) GST_TIME_AS_NSECONDS(buffer->duration) /  (double) 22675.736961451;

                  g_print("tstamp: %lld lenght: %lld                                            \n", tpos,tdur);
          } else {

                  g_print("no timestamp\n");
          }

          if(GST_BUFFER_FLAG_IS_SET(buffer, GST_BUFFER_FLAG_DISCONT)) {

                  g_print("discontinue!!!!!!\n");
          }

          g_print("Position in Bytes: ");

          GstIterator *elem_it = NULL;
          gboolean done = FALSE;

          elem_it = gst_bin_iterate_elements (GST_BIN (gst_object->decodebin));

          while (!done) {

                  GstElement *element = NULL;

                  switch (gst_iterator_next (elem_it, (gpointer) & element)) {
                  case GST_ITERATOR_OK:

                        fmt = GST_FORMAT_BYTES;

                        gint64 posbytes;
                        gint64 postime;

                        gst_element_query_position (element, &fmt, &posbytes);

                        fmt = GST_FORMAT_TIME;

                        gst_element_query_position (element, &fmt, &postime);

                        g_print("%s: %lld bytes %lld nanos,   ", gst_element_get_name(element), posbytes, postime);


                        gst_object_unref (element);

                        break;
                  case GST_ITERATOR_RESYNC:
                          gst_iterator_resync (elem_it);
                          break;
                  case GST_ITERATOR_ERROR:
                          done = TRUE;
                          break;
                  case GST_ITERATOR_DONE:
                          done = TRUE;
                          break;
                  }
          }
          gst_iterator_free (elem_it);

          fmt = GST_FORMAT_BYTES;

          gint64 possingle;

          gst_element_query_position (gst_object->audioconv, &fmt, &possingle);

          g_print(" and audioconvert : %lld,  ", possingle);

          g_print("\n\n");
        }


        gst_object->sample_pos += buffer->size/4;   /* FIXME: ugly ugly */

        gst_object->old_stream_byte_pos = gst_object->stream_byte_pos;

#endif

	if(gst_object->stream_server)
	  p0_streamserver_eat(gst_object->stream_server, (const char*)buffer->data, buffer->size);

        p0_alsa_handover_data(gst_object->alsa_object,
                              buffer->size,
                              buffer->data);

}


static void
p0_gst_add_audio_features (GHashTable *supportedFormats)
{
        GList *list = gst_type_find_factory_get_list();
        GList *iter;

        for (iter = list; iter; iter = iter->next) {
                GstTypeFindFactory *fac  = iter->data;
                const char         *mime = GST_PLUGIN_FEATURE_NAME (fac);

                if (! mime && ! *mime)
                        continue;

                if (g_str_has_prefix (mime, "audio/")      ||
                    strcmp (mime, "application/ogg") == 0  ||
                    strcmp (mime, "application/x-ogg") == 0)
                {
                        gchar *format;
                        gchar *type;

                        format = g_strdup (mime);
                        g_hash_table_insert (supportedFormats, format, format);

                        /*  for some formats the XDG MIME database has
                         *  a different idea of the correct type
                         */
                        type = g_content_type_from_mime_type (mime);

                        if (type && strcmp (type, format))
                                g_hash_table_insert (supportedFormats,
                                                     type, type);
                        else
                                g_free (type);
                }
        }

        gst_plugin_feature_list_free (list);
}

gchar *
p0_gst_get_supported_protocols_string (void)
{
        GHashTable     *supportedFormats;
        GHashTableIter  iter;
        gpointer        key;
        gpointer        value;
        GString        *str      = g_string_new ("");
        gboolean        addComma = FALSE;

        supportedFormats = g_hash_table_new_full (g_str_hash, g_str_equal,
                                                  NULL,
                                                  (GDestroyNotify) g_free);

        p0_gst_add_audio_features (supportedFormats);

        g_hash_table_iter_init (&iter, supportedFormats);

        while (g_hash_table_iter_next (&iter, &key, &value)) {
                if (addComma) {
                        str = g_string_append_c (str, ',');
                }
                str = g_string_append (str, "http-get:*:");
                str = g_string_append (str, (const char *) value);
                str = g_string_append (str, ":*");
                addComma = TRUE;
        }

        g_hash_table_destroy (supportedFormats);

        return g_string_free (str, FALSE);
}

int p0_gst_get_out_stream_port(P0Gst *gst)
{
  if(gst->stream_server)
	  return p0_streamserver_get_port(gst-> stream_server);
  return -1;
}
