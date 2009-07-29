/*
 * p0-alsa-capture.h
 *
 *  Created on: Jun 1, 2009
 *      Author: mhirsch
 */

#ifndef P0ALSACAPTURE_H_
#define P0ALSACAPTURE_H_



gboolean p0_alsa_audio_capture_init(gchar *device_name_capture);
gboolean p0_alsa_audio_capture_exit();
void	 p0_alsa_audio_capture_get_minmax(gint *max_l, gint *max_r );



#endif /* P0ALSACAPTURE_H_ */
