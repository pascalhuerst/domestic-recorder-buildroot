
#include <stdlib.h>
#include <glib.h>
#include <gio/gio.h>
#include "options.h"


static const gchar *host_ip         = NULL;
static const gchar *input_device    = NULL;
static const gchar *mixer_device    = NULL;
static const gchar *playback_device = NULL;
static const gchar *capture_device  = NULL;
static const gchar *udn             = NULL;
static gint         server_port     = -1;
static gint         verbose         = 1;
static gboolean     hwclock         = FALSE;
static gint         starttranstime  = 10;


static gboolean  option_fatal_warnings (const gchar  *option_name,
                                        const gchar  *value,
                                        gpointer      data,
                                        GError      **error);

static const GOptionEntry options[] =
{
  {
    "network", 'n', 0, G_OPTION_ARG_STRING, &host_ip,
    "Network interface to use", "<ip-address>"
  },
  {
    "input", 'i', 0, G_OPTION_ARG_STRING, &input_device,
    "Input device", "<device-name>"
  },
  {
    "mixer", 'm', 0, G_OPTION_ARG_STRING, &mixer_device,
    "Mixer device", "<device-name>"
  },
  {
    "playback", 'p', 0, G_OPTION_ARG_STRING, &playback_device,
    "Playback device", "<device-name>"
  },
  {
    "capture", 'c', 0, G_OPTION_ARG_STRING, &capture_device,
    "capture device", "<device-name>"
  },

  {
    "udn", 'u', 0, G_OPTION_ARG_STRING, &udn,
    "Override the system UDN", "<uuid>"
  },
  {
    "verbose", 'v', 0, G_OPTION_ARG_INT, &verbose,
    "verbose level, (default=1)", NULL
  },
  {
    "hwclock", 'w', 0, G_OPTION_ARG_NONE, &hwclock,
    "use the raumfeld HW adjustable clock", NULL
  },
  {
    "starttransient", 's', 0, G_OPTION_ARG_INT, &starttranstime,
    "manipulate the start transient time (default=10)", NULL
  },
  {
    "raw", 'r', 0, G_OPTION_ARG_INT, &server_port,
    "All gst output will be http-served on the given port", "<port>"
  },
  {
    "g-fatal-warnings", 0, G_OPTION_FLAG_NO_ARG,
    G_OPTION_ARG_CALLBACK, option_fatal_warnings,
    "Make all warnings fatal", NULL
  },
  { NULL }
};

static gboolean
option_fatal_warnings (const gchar  *option_name,
                       const gchar  *value,
                       gpointer      data,
                       GError      **error)
{
  GLogLevelFlags fatal_mask;

  fatal_mask = g_log_set_always_fatal (G_LOG_FATAL_MASK);
  fatal_mask |= G_LOG_LEVEL_WARNING | G_LOG_LEVEL_CRITICAL;

  g_log_set_always_fatal (fatal_mask);

  return TRUE;
}


GOptionContext *
option_context_new (const gchar *parameter)
{
  GOptionContext *context;

  context = g_option_context_new (parameter);

  g_option_context_add_main_entries (context, options, NULL);

  return context;
}

void
options_show_help (GOptionContext *context)
{
  gchar *help;

  g_return_if_fail (context != NULL);

  help = g_option_context_get_help (context, TRUE, NULL);
  g_print ("%s\n", help);
  g_free (help);
}

const gchar *
options_get_host_ip (void)
{
  return host_ip;
}

const gchar *
options_get_input_device (void)
{
  return input_device;
}

const gchar *
options_get_playback_device (void)
{
  return playback_device;
}

const gchar *
options_get_capture_device (void)
{
  return capture_device;
}

const gchar *
options_get_mixer_device (void)
{
  return mixer_device;
}

const gchar *
options_get_udn (void)
{
  return udn;
}

gint
options_get_verbose (void)
{
  return verbose;
}

gint
options_get_server_port (void)
{
  return server_port;
}

gboolean
options_get_hwclock (void)
{
  return hwclock;
}

gint
options_get_start_transient (void)
{
  return starttranstime;
}
