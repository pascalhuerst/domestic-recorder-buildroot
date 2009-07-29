/*
 * p0-alsa-tools.h
 *
 *  Created on: May 22, 2009
 *      Author: mhirsch
 */

#ifndef P0ALSATOOLS_H_
#define P0ALSATOOLS_H_

#include <alsa/asoundlib.h>


gint p0_alsa_tools_set_playback_params	(const gchar *device_name_playback,
                                         snd_pcm_t** playback_handle,
                                         snd_pcm_hw_params_t* hwparams,
                                         snd_pcm_sw_params_t* swparams,
                                         snd_pcm_uframes_t*   frames_per_period,
                                         snd_pcm_uframes_t*   ringbufferframes);

gint p0_alsa_tools_set_capture_params	(const gchar *device_name_capture,
                                         snd_pcm_t** capture_handle,
                                         snd_pcm_hw_params_t* hwparams,
                                         snd_pcm_sw_params_t* swparams,
                                         snd_pcm_uframes_t*   frames_per_period,
                                         snd_pcm_uframes_t*   ringbufferframes);

snd_pcm_sframes_t p0_alsa_tools_get_delay(snd_pcm_t* playback_handle);


gboolean p0_alsa_tools_open_hw_clock 	();

gboolean p0_alsa_tools_write_hw_clock 	(gint value);

gboolean p0_alsa_tools_close_hw_clock 	();

gdouble	p0_alsa_tools_get_hw_clock_ppm	(const gchar *device_name_playback);


#endif /* P0ALSATOOLS_H_ */
