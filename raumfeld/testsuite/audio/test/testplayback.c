/*
 * testplayback.c
 *
 *  Created on: Jul 2, 2009
 *      Author: mhirsch
 */



#include <stdio.h>
#include <alsa/asoundlib.h>
#include <glib-object.h>
#include "../p0-alsa-tools.h"
#include "values.h"
#include "testplayback.h"

#include <math.h>
#include <pthread.h>

static double phase[2] = {0, 0};
static int Freq = 0;
static int terminate_loop = FALSE;


double generate_sine_wave(unsigned int amplitude, double frequency, double *phase)
{
        double sine_val;
        double phasestep = (2 * M_PI * frequency * (1 / (double)SAMPLERATE));

        sine_val = amplitude * sin(*phase);

        *phase += phasestep;

        if (*phase > 2 * M_PI)
                *phase -= 2 * M_PI;

        return sine_val;
}



void generate_wave(unsigned char *buffer,  snd_pcm_uframes_t period_size, test_params_t *values)
{
        double val1 = 0;
        short *samples = (short *) buffer;
        int k=0;


        while(period_size-- > 0)
        {
                if(!values->mute)
                        val1 = generate_sine_wave(values->Amplitude, values->Freq, &phase[0]);
                else
                    val1 = 0;

                samples[k] = val1;
                k++;
                samples[k] = val1;
                k++;
        }
}




gint play_sinus(const gchar *device_name_playback, test_params_t *test_params)
{

        snd_pcm_t* playback_handle;

        snd_pcm_hw_params_t* hwparams_playback;
        snd_pcm_sw_params_t* swparams_playback;

        snd_pcm_uframes_t frames_per_period;
        snd_pcm_uframes_t ringbufferframes;

        snd_pcm_uframes_t frame_cnt;

        guchar* buffer;
        gint err;


        terminate_loop = FALSE;

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

        generate_wave(buffer,ringbufferframes, test_params);

        if (snd_pcm_writei(playback_handle,
                           buffer,
                           ringbufferframes) != ringbufferframes)
                g_error("!!!->Alsa: cant write to pcm while calibration\n");

        err = snd_pcm_start(playback_handle);

        if (err < 0)
                g_error("!!->Alsa: Start error: %s\n", snd_strerror(err));

        frame_cnt = ringbufferframes;

        while (!terminate_loop)
        {

                generate_wave(buffer, frames_per_period, test_params);
                if(snd_pcm_writei(playback_handle, buffer, frames_per_period) != frames_per_period)
                        g_error("!!!->Alsa: cant write to pcm while calibration\n");

                frame_cnt += frames_per_period;
                num_periods++;
        }

        g_print("finished\n");

        g_free(buffer);

        snd_pcm_drain(playback_handle);
        snd_pcm_close(playback_handle);

        return 0;
}



gint stop_sinus()
{
        terminate_loop = TRUE;

        return 0;
}

