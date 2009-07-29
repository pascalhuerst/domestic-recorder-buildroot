/*
 * P0Input:
 *
 * This class reads input events from the rotary encoder.
 */

#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

#include <linux/input.h>

#include <glib-object.h>

#include "p0-renderer-types.h"
#include "p0-input.h"


struct _P0Input
{
        GObject  parent_instance;

        guint    source;
};

enum
{
        TURN,
        LAST_SIGNAL
};


static void  p0_input_dispose (GObject *object);


G_DEFINE_TYPE (P0Input, p0_input, G_TYPE_OBJECT)

static guint p0_input_signals[LAST_SIGNAL] = { 0 };


static void
p0_input_class_init (P0InputClass* klass)
{
        GObjectClass *object_class = G_OBJECT_CLASS (klass);

        object_class->dispose = p0_input_dispose;

        p0_input_signals[TURN] =
                g_signal_new ("turn",
                              G_TYPE_FROM_CLASS (klass),
                              G_SIGNAL_RUN_FIRST,
                              G_STRUCT_OFFSET (P0InputClass, turn),
                              NULL, NULL,
                              g_cclosure_marshal_VOID__INT,
                              G_TYPE_NONE, 1, G_TYPE_INT);
}

static void
p0_input_dispose (GObject *object)
{
       P0Input *input = P0_INPUT (object);

       if (input->source) {
               g_source_remove (input->source);
               input->source = 0;
       }

       G_OBJECT_CLASS (p0_input_parent_class)->dispose (object);
}

static void
p0_input_init (P0Input *input)
{
}

static gboolean
p0_input_readable (GIOChannel   *io,
                   GIOCondition  condition,
                   gpointer      data)
{
        P0Input            *input      = data;
        gsize               bytes_read = 0;
        struct input_event  buf[8];

        g_return_val_if_fail (condition == G_IO_IN, FALSE);

        if (g_io_channel_read_chars (io,
                                     (gchar *) &buf, sizeof (buf),
                                     &bytes_read,
                                     NULL) == G_IO_STATUS_NORMAL)
          {
                const struct input_event *event;
                const gint                num   = (bytes_read /
                                                   sizeof (struct input_event));
                gint                      value = 0;
                gint                      i;

                for (event = buf, i = 0; i < num; event++, i++)
                {
                        if (event->type == EV_REL &&
                            event->code == REL_X)
                                value += event->value;
                }

                if (value)
                        g_signal_emit (input, p0_input_signals[TURN], 0, value);
        }

        return TRUE;
}

P0Input *
p0_input_new (const gchar *device)
{
        P0Input    *input;
        GIOChannel *io;
        gint        fd;
        gchar       buf[128];

        g_return_val_if_fail (device != NULL, NULL);

        g_print ("->Input: opening input device %s\n", device);

        fd = open (device, O_RDWR);
        if (fd < 0) {
                g_printerr ("->Input: unable to open input device: %s\n",
                            g_strerror (errno));
                return NULL;
        }

        /* get device name */
        memset (buf, 0, sizeof (buf));
        ioctl (fd, EVIOCGNAME (sizeof (buf) - 1), &buf);

        g_print ("->Input: listening for events from %s\n",
                 strlen (buf) ? buf : "<unknown>");

        input = g_object_new (TYPE_P0_INPUT, NULL);

        io = g_io_channel_unix_new (fd);

        g_io_channel_set_encoding (io, NULL, NULL);
        g_io_channel_set_buffered (io, FALSE);
        g_io_channel_set_close_on_unref (io, TRUE);

        input->source = g_io_add_watch (io, G_IO_IN, p0_input_readable, input);

        g_io_channel_unref (io);

        return input;
}
