#ifndef __OPTIONS_H__
#define __OPTIONS_H__

GOptionContext * option_context_new          (const gchar    *parameter);

void             options_show_help           (GOptionContext *context);

const gchar    * options_get_host_ip         (void);
const gchar    * options_get_input_device    (void);
const gchar    * options_get_mixer_device    (void);
const gchar    * options_get_playback_device (void);
const gchar    * options_get_capture_device  (void);
const gchar    * options_get_udn             (void);
gint         	 options_get_verbose         (void);
gboolean         options_get_hwclock         (void);
gint             options_get_start_transient (void);
gint             options_get_server_port     (void);

#endif /* __OPTIONS_H__ */
