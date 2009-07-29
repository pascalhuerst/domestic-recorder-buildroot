
#include <stdlib.h>
#include <string.h>
#include <signal.h>

#include <dbus/dbus-glib.h>
#include <dbus/dbus-glib-lowlevel.h>

#include <gst/gst.h>
#include <libgupnp/gupnp.h>
#include <raumfeld/time.h>

#include "p0-renderer-types.h"
#include "options.h"
#include "p0-alsa.h"
#include "p0-control.h"
#include "p0-dbus-service.h"
#include "p0-feedback.h"
#include "p0-gst.h"
#include "p0-input.h"
#include "p0-mixer.h"
#include "p0-renderer.h"
#include "p0-transport.h"


static GMainLoop *main_loop = NULL;

static void
interrupt_signal_handler (int signum)
{
        if (main_loop) {
                g_printerr ("exiting ...\n");

                g_main_loop_quit (main_loop);
                g_main_loop_unref (main_loop);

                main_loop = NULL;
        }
}

static void
input_turned (P0Input *input,
              gint     amount,
              P0Mixer *mixer)
{
        gint volume = p0_mixer_get_volume (mixer) + 5 * amount;

        p0_mixer_set_volume (mixer, CLAMP (volume, 0, 100));
}


static void
tag_found (P0Gst        *gst,
           const gchar  *tag,
           const GValue *value)
{
  g_printerr ("tag   : %s\n", tag);

  if (G_VALUE_HOLDS_STRING (value))
    {
      g_printerr ("value : %s\n", g_value_get_string (value));
    }
  else
    {
      GValue tmp = { 0, };

      g_value_init (&tmp, G_TYPE_STRING);

      if (g_value_transform (value, &tmp))
        {
          g_printerr ("value : %s\n", g_value_get_string (&tmp));
        }

      g_value_unset (&tmp);
    }
}

int
main (int    argc,
      char **argv)
{
        GOptionContext    *options;
        GUPnPContext      *context;
        DBusGConnection   *dbus_connection;
        P0Feedback        *feedback;
        P0Renderer        *renderer;
        P0Transport       *transport;
        P0Gst             *streamer;
        P0Alsa            *alsa;
        P0Mixer           *mixer;
        P0DBusService     *service     = NULL;
        P0Input           *input       = NULL;
        TimeClient        *time_client = NULL;
        GError            *error       = NULL;
        struct sigaction   sig_action;

        /* Init */
        g_thread_init (NULL);
        g_type_init ();

        g_set_application_name ("Raumfeld Audio Renderer");

        /*  parse command-line options  */
        options = option_context_new (NULL);
        g_option_context_add_group (options,
                                    gst_init_get_option_group ());

        if (! g_option_context_parse (options, &argc, &argv, &error)) {
                g_print ("%s\n", error->message);
                g_error_free (error);

                return EXIT_FAILURE;
        }

        if (argc != 1) {
                options_show_help (options);
                return EXIT_FAILURE;
        }

        g_option_context_free (options);

        context = gupnp_context_new (NULL, options_get_host_ip (), 0, &error);

        if (! context) {
                g_printerr ("Error creating GUPnPContext: %s\n",
                            error->message);

                g_error_free (error);

                return EXIT_FAILURE;
        }

        time_client = time_client_create (GSSDP_CLIENT (context), NULL);

        if (! time_client)
                return EXIT_FAILURE;

        g_return_val_if_fail (TIME_IS_CLIENT (time_client), EXIT_FAILURE);

        feedback = p0_feedback_new ();

        /* set up our UPNP device */
        renderer = p0_renderer_new (context,
                                    options_get_udn (),
                                    time_client_get_usn (time_client),
                                    feedback);
        g_object_unref (context);

        /* set up alsa */
        alsa = p0_alsa_new (time_client,
                            options_get_playback_device (),
                            options_get_capture_device (),
                            feedback);


        /* set up the gstreamer instance */
        streamer = p0_gst_new ();

        g_signal_connect (streamer, "tag-found",
                          G_CALLBACK (tag_found),
                          NULL);


        g_object_unref (time_client);
        g_object_unref (feedback);

        p0_gst_set_alsa_ptr (streamer, alsa);

        /* connecting signals */
        transport = p0_renderer_get_av_transport (renderer);

        g_signal_connect_swapped (transport, "set-uri-called",
                                  G_CALLBACK (p0_gst_start_streaming),
                                  streamer);

        g_signal_connect_swapped (transport, "play-called",
                                  G_CALLBACK (p0_alsa_notify_play_pressed),
                                  alsa);

        g_signal_connect_swapped (transport, "stop-called",
                                  G_CALLBACK (p0_gst_stop_streaming),
                                  streamer);

        g_signal_connect_swapped (alsa, "playstate-changed",
                                  G_CALLBACK (p0_transport_notify_playstate),
                                  transport);

        g_signal_connect_swapped (alsa, "error-occured",
                        G_CALLBACK (p0_gst_notify_error),
                        streamer);

        g_signal_connect_swapped (transport, "trigger-set",
                        G_CALLBACK (p0_alsa_set_next_trigger_time),
                        alsa);

        g_signal_connect_swapped (alsa, "buffer-filled",
                        G_CALLBACK (p0_transport_notify_buffer_filled),
                        transport);

        mixer = p0_mixer_new(options_get_mixer_device());
        if (mixer)
        {
                P0Control *control;
                const gchar *device_name;

                control = p0_renderer_get_rendering_control(renderer);
                p0_control_set_mixer(control,
                                     mixer);

                p0_control_set_alsa(control,
                                     alsa);

                g_object_unref(mixer);

                device_name = options_get_input_device();

                if (device_name)
                {
                        input = p0_input_new(device_name);

                        if (input)
                                g_signal_connect (input, "turn",
                                                G_CALLBACK (input_turned),
                                                mixer);
                }
        }

        /*  start the UPnP Renderer  as soon as alsa is ready  */
        g_signal_connect_swapped (alsa, "ready",
                        G_CALLBACK (p0_renderer_run),
                        renderer);

        /*  set up the dbus-service  */
        dbus_connection = dbus_g_bus_get (DBUS_BUS_SESSION, &error);

        if (dbus_connection) {
                service = p0_dbus_service_new ();

                // FIXME: this should actually be connected to the mute state
                //        of the amplifier, not directly to the play-state of
                //        of the alsa object
                g_signal_connect_swapped (alsa, "playstate-changed",
                                          G_CALLBACK (p0_dbus_service_notify_playstate),
                                          service);

                dbus_bus_request_name (dbus_g_connection_get_connection (dbus_connection),
                                       P0_DBUS_SERVICE_NAME, 0, NULL);

                dbus_g_connection_register_g_object (dbus_connection,
                                                     P0_DBUS_SERVICE_PATH,
                                                     G_OBJECT (service));
        }
        else {
                g_printerr ("%s\n", error->message);
                g_error_free (error);
        }

        /*  eventually start the alsa threads  */
        p0_alsa_run (alsa);

        /*  tell the control object where clients can find the stream we are serving  */
        p0_control_set_out_stream_adress(p0_renderer_get_rendering_control(renderer),
                                         gupnp_context_get_host_ip(context),
                                         p0_gst_get_out_stream_port(streamer));

        /* setup signal handler */
        memset (&sig_action, 0, sizeof(sig_action));
        sig_action.sa_handler = interrupt_signal_handler;
        sigaction (SIGINT, &sig_action, NULL);

        /* Start Main Loop */
        main_loop = g_main_loop_new (NULL, FALSE);
        g_main_loop_run (main_loop);

        if (input)
                g_object_unref (input);

        g_object_unref (renderer);
        g_object_unref (streamer);
        g_object_unref (alsa);

        if (service)
                g_object_unref (service);

        return EXIT_SUCCESS;
}
