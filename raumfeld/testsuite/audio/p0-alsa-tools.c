/*
 * p0-alsa-tools.c
 *
 *  Created on: May 22, 2009
 *      Author: mhirsch
 */

/****************************************
 * lot's of service Functions
 ****************************************/

#include <string.h>
#include <glib-object.h>
#include <raumfeld/time.h>

#include "p0-renderer-types.h"
#include "p0-alsa.h"
#include "p0-alsa-tools.h"

/**********************
 * alsa service functions
 * **********************/


static long long int time_diff_alsa_tools(const struct timeval *time1,
                        const struct timeval *time2)
{
        /* convenience function,
         * returns delta between time 1 and time 2 in uSec
         */
        struct timeval diff;

        timersub (time1, time2, &diff);

        return (long long int) diff.tv_sec * 1000000L + diff.tv_usec;
}





gint p0_alsa_tools_set_playback_params(const gchar * device_name_playback,
                                       snd_pcm_t** playback_handle_param,
                                       snd_pcm_hw_params_t* hwparams,
                                       snd_pcm_sw_params_t* swparams,
                                       snd_pcm_uframes_t* frames_per_period,
                                       snd_pcm_uframes_t* ringbufferframes)
{

        gint rc;
        guint samplerate;
        snd_pcm_t* playback_handle;

        g_print("->Alsa: opening playback device named %s\n",
                device_name_playback);

        /* Open and setup the soundcard */
        rc = snd_pcm_open(&playback_handle,
                          device_name_playback,
                          SND_PCM_STREAM_PLAYBACK,
                          0);

        if (rc < 0)
        {
                g_error ("!!->Alsa: unable to open pcm device: %s\n",
                                snd_strerror(rc));
                return rc;
        }

        *playback_handle_param = playback_handle;

        /* Fill it in with default values */
        snd_pcm_hw_params_any(playback_handle,
                              hwparams);

        /* Interleaved mode */
        snd_pcm_hw_params_set_access(playback_handle,
                                     hwparams,
                                     SND_PCM_ACCESS_RW_INTERLEAVED);

        /* Signed 16-bit little-endian format */
        snd_pcm_hw_params_set_format(playback_handle,
                                     hwparams,
                                     SND_PCM_FORMAT_S16_LE);

        /* Two channels (stereo) */
        snd_pcm_hw_params_set_channels(playback_handle,
                                       hwparams,
                                       2);

        /* 44100 bits/second sampling rate  */
        samplerate = SAMPLERATE;

        snd_pcm_hw_params_set_rate_near(playback_handle,
                                        hwparams,
                                        &samplerate,
                                        0);

        if (samplerate != SAMPLERATE)
        {
                g_printerr("!!->Alsa: samplerate != %d : %d\n",
                           SAMPLERATE,
                           samplerate);

        }

        /* Set period size and ringbuffer */
        *frames_per_period = FRAMESPERPERIODE;

        snd_pcm_hw_params_set_period_size_near(playback_handle,
                                               hwparams,
                                               frames_per_period,
                                               0);

        /* Write the parameters to the driver */
        rc = snd_pcm_hw_params(playback_handle,
                               hwparams);

        if (rc < 0)
        {
                snd_output_t* errlog;

                snd_output_stdio_attach(&errlog,
                                        stderr,
                                        0);

                snd_pcm_hw_params_dump(hwparams,
                                       errlog);

                g_print("!!->Alsa: unable to set hw parameters: %s\n",
                        snd_strerror(rc));
                return -1;
        }

        /*
         snd_output_t* errlog;

         snd_output_stdio_attach(&errlog, stderr, 0);

         snd_pcm_hw_params_dump(hwparams, errlog);
         */

        /* get the current swparams */
        rc = snd_pcm_sw_params_current(playback_handle,
                                       swparams);

        if (rc < 0)
        {
                g_print("Unable to determine current swparams for playback: %s\n",
                        snd_strerror(rc));

                return rc;
        }

        /* start the transfer when the buffer is almost full: */
        /* (buffer_size / avail_min) * avail_min */
        /* this is so stupid */
        rc = snd_pcm_sw_params_set_start_threshold(playback_handle,
                                                   swparams,
                                                   10000000);

        if (rc < 0)
        {
                g_print("Unable to set start threshold mode for playback: %s\n",
                        snd_strerror(rc));

                return rc;
        }

        /* write the parameters to the playback device */
        rc = snd_pcm_sw_params(playback_handle,
                               swparams);

        if (rc < 0)
        {
                printf("Unable to set sw params for playback: %s\n",
                       snd_strerror(rc));

                return rc;
        }

        /* retreive the actual and real values from the soundcard */
        snd_pcm_hw_params_get_period_size(hwparams,
                                          frames_per_period,
                                          0);

        snd_pcm_hw_params_get_buffer_size(hwparams,
                                          ringbufferframes);

#ifdef P0ARMWORKAROUND
        /* PXA HACKHACK */
        *frames_per_period = FRAMESPERPERIODE;
#endif

        /* allocate the data buffers */
        g_print("->Alsa: ringbufferframes: %d periodframes:%d\n",
                (int) *ringbufferframes,
                (int) *frames_per_period);

        return 0;
}

gint p0_alsa_tools_set_capture_params(const gchar * device_name_capture,
                                      snd_pcm_t** capture_handle_param,
                                      snd_pcm_hw_params_t* hwparams,
                                      snd_pcm_sw_params_t* swparams,
                                      snd_pcm_uframes_t* frames_per_period,
                                      snd_pcm_uframes_t* ringbufferframes)
{
        gint rc;
        guint samplerate;
        snd_pcm_t* capture_handle;

        g_print("->Alsa: opening capture device named %s\n",
                device_name_capture);

        /* Open and setup the soundcard */
        rc = snd_pcm_open(&capture_handle,
                          device_name_capture,
                          SND_PCM_STREAM_CAPTURE,
                          0);

        if (rc < 0)
        {
                g_error ("!!->Alsa: unable to open pcm device: %s\n",
                                snd_strerror(rc));
                return rc;
        }

        *capture_handle_param = capture_handle;

        /* Fill it in with default values */
        snd_pcm_hw_params_any(capture_handle,
                              hwparams);

        /* Interleaved mode */
        snd_pcm_hw_params_set_access(capture_handle,
                                     hwparams,
                                     SND_PCM_ACCESS_RW_INTERLEAVED);

        /* Signed 16-bit little-endian format */
        snd_pcm_hw_params_set_format(capture_handle,
                                     hwparams,
                                     SND_PCM_FORMAT_S16_LE);

        /* Two channels (stereo) */
        snd_pcm_hw_params_set_channels(capture_handle,
                                       hwparams,
                                       2);

        /* 44100 bits/second sampling rate  */
        samplerate = SAMPLERATE;

        snd_pcm_hw_params_set_rate_near(capture_handle,
                                        hwparams,
                                        &samplerate,
                                        0);
        if (samplerate != SAMPLERATE)
        {
                g_printerr("!!->Alsa: samplerate != %d : %d\n",
                           SAMPLERATE,
                           samplerate);

        }

        /* Set period size and ringbuffer */
        *frames_per_period = FRAMESPERPERIODE;

        snd_pcm_hw_params_set_period_size_near(capture_handle,
                                               hwparams,
                                               frames_per_period,
                                               0);

        /* Write the parameters to the driver */
        rc = snd_pcm_hw_params(capture_handle,
                               hwparams);

        if (rc < 0)
        {
                snd_output_t* errlog;

                snd_output_stdio_attach(&errlog,
                                        stderr,
                                        0);

                snd_pcm_hw_params_dump(hwparams,
                                       errlog);

                g_print("!!->Alsa: unable to set hw parameters: %s\n",
                        snd_strerror(rc));
                return -1;
        }

        /*
         snd_output_t* errlog;

         snd_output_stdio_attach(&errlog, stderr, 0);

         snd_pcm_hw_params_dump(hwparams, errlog);
         */

        /* get the current swparams */
        rc = snd_pcm_sw_params_current(capture_handle,
                                       swparams);

        if (rc < 0)
        {
                g_print("Unable to determine current swparams for playback: %s\n",
                        snd_strerror(rc));

                return rc;
        }

        /* start the transfer when the buffer is almost full: */
        /* (buffer_size / avail_min) * avail_min */
        /* this is so stupid */
        rc = snd_pcm_sw_params_set_start_threshold(capture_handle,
                                                   swparams,
                                                   10000000);

        if (rc < 0)
        {
                g_print("Unable to set start threshold mode for playback: %s\n",
                        snd_strerror(rc));

                return rc;
        }

        /* write the parameters to the playback device */
        rc = snd_pcm_sw_params(capture_handle,
                               swparams);

        if (rc < 0)
        {
                printf("Unable to set sw params for playback: %s\n",
                       snd_strerror(rc));

                return rc;
        }

        /* retreive the actual and real values from the soundcard */
        snd_pcm_hw_params_get_period_size(hwparams,
                                          frames_per_period,
                                          0);

        snd_pcm_hw_params_get_buffer_size(hwparams,
                                          ringbufferframes);

#ifdef P0ARMWORKAROUND
        /* PXA HACKHACK */
        *frames_per_period = FRAMESPERPERIODE;
#endif

        /* allocate the data buffers */
        g_print("->Alsa: ringbufferframes: %d periodframes:%d\n",
                (int) *ringbufferframes,
                (int) *frames_per_period);

        return 0;
}

snd_pcm_sframes_t p0_alsa_tools_get_delay(snd_pcm_t* playback_handle)
{
        int err;

        snd_pcm_status_t *status;

        snd_pcm_status_alloca(&status);

        if ((err = snd_pcm_status(playback_handle,
                                  status)) < 0)
        {
                g_print("!!->Alsa: Stream status error: %s\n",
                        snd_strerror(err));

                return 0;
        }

        return snd_pcm_status_get_delay(status);
}

#define HWCLOCKFILE                 "/sys/bus/spi/drivers/dac7512/spi0.2/value"
static int hw_clock_file;

gboolean p0_alsa_tools_open_hw_clock()
{
        hw_clock_file = open(HWCLOCKFILE,
                             O_WRONLY | O_SYNC);

        if (hw_clock_file < 0)
                return FALSE;

        return TRUE;
}

gboolean p0_alsa_tools_close_hw_clock()
{
        close(hw_clock_file);

        if (hw_clock_file < 0)
                g_error("!!!->Alsa: cant open hw clock file %s \n",HWCLOCKFILE);

        return TRUE;
}

gboolean p0_alsa_tools_write_hw_clock(gint value)
{
        char buffer[16];

        sprintf(buffer,
                "%d\n",
                value);

        if (write(hw_clock_file,
                  buffer,
                  strlen(buffer)) != strlen(buffer))
                g_error("!!!->Alsa: cant write to %s \n",HWCLOCKFILE);

        return TRUE;
}

#define CALIBRATION_CYCLES 200

gdouble p0_alsa_tools_get_hw_clock_ppm(const gchar *device_name_playback)
{

        snd_pcm_t* playback_handle;

        snd_pcm_hw_params_t* hwparams_playback;
        snd_pcm_sw_params_t* swparams_playback;

        snd_pcm_uframes_t frames_per_period;
        snd_pcm_uframes_t ringbufferframes;

        snd_pcm_uframes_t frame_cnt;
        snd_pcm_uframes_t start_frames;
        snd_pcm_uframes_t now_frames;
        struct timeval start_time;
        struct timeval now_time;

        gfloat frame_per_sec = 0;

        gchar* buffer;
        gint err;

        gint num_periods = 0;

        /* Allocate a hardware parameters object */
        snd_pcm_hw_params_alloca(&hwparams_playback);
        snd_pcm_sw_params_alloca(&swparams_playback);

        if (p0_alsa_tools_set_playback_params(device_name_playback,
                                              &playback_handle,
                                              hwparams_playback,
                                              swparams_playback,
                                              &frames_per_period,
                                              &ringbufferframes) < 0)
                return FALSE;

        buffer = g_malloc(ringbufferframes * BYTESPERFRAME);

        memset(buffer,0,ringbufferframes * BYTESPERFRAME);

        if (snd_pcm_writei(playback_handle,
                           buffer,
                           ringbufferframes) != ringbufferframes)
                g_error("!!!->Alsa: cant write to pcm while calibration\n");

        err = snd_pcm_start(playback_handle);

        if (err < 0)
                g_error("!!->Alsa: Start error: %s\n", snd_strerror(err));

        frame_cnt = ringbufferframes;

        while (num_periods < CALIBRATION_CYCLES)
        {

                now_frames = frame_cnt - p0_alsa_tools_get_delay(playback_handle);

                if (!num_periods)
                {
                        gettimeofday(&start_time,
                                     NULL);
                        start_frames = now_frames;
                } else
                {
                        gettimeofday(&now_time,
                                     NULL);

                        long long int tdiff = time_diff_alsa_tools(&now_time,
                                                        &start_time);
                        int frame_diff = now_frames - start_frames;

                        frame_per_sec = (float) frame_diff * 1000* 1000 / (float ) tdiff;
                }

                if(snd_pcm_writei(playback_handle, buffer, frames_per_period) != frames_per_period)
                        g_error("!!!->Alsa: cant write to pcm while calibration\n");

                frame_cnt += frames_per_period;
                num_periods++;
        }

        g_print("->Alsa: Calibrations result : %2.6f frames/sec\n", frame_per_sec);

        g_free(buffer);

        snd_pcm_drain(playback_handle);
        snd_pcm_close(playback_handle);

        return frame_per_sec;
}

