/*
 * testcapture.c
 *
 *  Created on: Jul 2, 2009
 *      Author: mhirsch
 */

/*
 * p0-alsa-capture.c
 *
 *  Created on: Jun 1, 2009
 *      Author: mhirsch
 */



#include <stdio.h>
#include <alsa/asoundlib.h>
#include <glib-object.h>
#include <math.h>
#include <liboil/liboil.h>
#include "../p0-alsa-tools.h"
#include "../p0-dsp.h"
typedef struct _P0Eq  P0Eq;

#include "../p0-eq.h"
#include "values.h"
#include "testcapture.h"

typedef struct
{
        snd_pcm_t*              capture_handle;

        snd_pcm_hw_params_t*    hwparams_capture;
        snd_pcm_sw_params_t*    swparams_capture;

        snd_pcm_uframes_t       frames_per_period_capture;
        snd_pcm_uframes_t       ringbufferframes_capture;

        guint64                 byte_pos;

        gboolean                terminate_loop;

        GThread*                audio_capture_thread;
        gchar*                  buffer_alsa_capture;

        gint                    max_l;
        gint                    max_r;

} AlsaCaptureData;

static AlsaCaptureData AlsaCapture;
static gpointer audio_capture_loop(gpointer ptr);


void test_check(float dB0l, float dB0r,  test_params_t *params)
{

        if(dB0l < params->minDB)
                g_error("channel 0 has %2.4f minimum is: %2.4f", dB0l,params->minDB);
        if(dB0r < params->minDB)
                g_error("channel 1 has %2.4f minimum is: %2.4f", dB0r,params->minDB );
        if(dB0l > params->maxDB)
                g_error("channel 0 has %2.4f maximum is: %2.4f", dB0l,params->maxDB );
        if(dB0r > params->maxDB)
                g_error("channel 1 has %2.4f maximum is: %2.4f", dB0r,params->maxDB );

}




gint
test_capture(const gchar *device_name_capture_param, test_params_t *params)
{

        snd_pcm_sframes_t rc=0;
        snd_pcm_sframes_t sumframes=0;

        int err;
        int i;

        P0Eq            *eq[2];
        gint32          *eq_buffer;
        EQParameters    eq_params;


        snd_pcm_hw_params_alloca(&AlsaCapture.hwparams_capture);

        snd_pcm_sw_params_alloca(&AlsaCapture.swparams_capture);

        if (p0_alsa_tools_set_capture_params(device_name_capture_param,
                                             &AlsaCapture.capture_handle,
                                             AlsaCapture.hwparams_capture,
                                             AlsaCapture.swparams_capture,
                                             &AlsaCapture.frames_per_period_capture,
                                             &AlsaCapture.ringbufferframes_capture))
                return FALSE;

        AlsaCapture.terminate_loop = FALSE;

        AlsaCapture.buffer_alsa_capture = (char*) malloc(AlsaCapture.ringbufferframes_capture * 4);

        memset(AlsaCapture.buffer_alsa_capture,
               0,
               AlsaCapture.ringbufferframes_capture);


        if(params->doFilter)
        {
                eq_buffer = (gint32*) malloc(CAPTUREPERIODFRAMES * sizeof (gint32) * 4);

                int e;
                for(e=0; e<2; e++)
                {
                        eq[e] = p0_eq_new(SAMPLERATE,ZP_STEREO,ZP_TYPE_INT32 );

                        p0_eq_getparams(eq[e], &eq_params);

                        eq_params.Filter1Mode = PARAMETRIC;
                        eq_params.fFilter1MidFreq = params->Freq;
                        eq_params.fFilter1Q = 100.0;
                        eq_params.fFilter1Gain = -18.0;

                        eq_params.fFilter2MidFreq = params->Freq;
                        eq_params.fFilter2Q = 100.0;
                        eq_params.fFilter2Gain = -18.0;
                        eq_params.Filter3Mode = PARAMETRIC;
                        eq_params.fFilter3MidFreq = params->Freq;
                        eq_params.fFilter3Q = 100.0;
                        eq_params.fFilter3Gain = -18.0;

                        p0_eq_setparams(eq[e], &eq_params);
                }
        }

        err = snd_pcm_start(AlsaCapture.capture_handle);

        g_print("\n");

        if (err < 0)
                g_error("!!->Alsa: Start error: %s\n",
                                snd_strerror(err));

        while (sumframes < TESTLENGTH * SAMPLERATE)
        {

                rc = snd_pcm_readi(AlsaCapture.capture_handle,
                                   AlsaCapture.buffer_alsa_capture,
                                   CAPTUREPERIODFRAMES);



                if (rc != CAPTUREPERIODFRAMES )
                {
                        g_error("!!->Alsa: something wrong happend while captureing\n");
                }


                if(params->doFilter)
                {
                        oil_conv_s32_s16(eq_buffer,
                                         sizeof(gint32),
                                         (short *) AlsaCapture.buffer_alsa_capture,
                                         sizeof(short),
                                         CAPTUREPERIODFRAMES * 2);

                        for(i=0; i < CAPTUREPERIODFRAMES *2; i++)
                        {
                                eq_buffer[i] = eq_buffer[i]<<16;
                        }

                        p0_eq_process(eq[0], eq_buffer, CAPTUREPERIODFRAMES);
                        p0_eq_process(eq[1], eq_buffer, CAPTUREPERIODFRAMES);

                        for(i=0; i < CAPTUREPERIODFRAMES * 2; i++)
                        {
                                eq_buffer[i] = eq_buffer[i]>>16;
                        }


                        oil_clipconv_s16_s32((short *) AlsaCapture.buffer_alsa_capture,
                                             sizeof(short),
                                             eq_buffer,
                                             sizeof(gint32),
                                             CAPTUREPERIODFRAMES * 2);
                }

                p0_dsp_get_minmax((short *) AlsaCapture.buffer_alsa_capture,
                                  CAPTUREPERIODFRAMES,
                                  &AlsaCapture.max_l,
                                  &AlsaCapture.max_r);



                float dB0l = 20.0 *log10((float)AlsaCapture.max_l/32767.0);
                float dB0r = 20.0 *log10((float)AlsaCapture.max_r/32767.0);

                if(sumframes)
                        test_check(dB0l, dB0r,  params);

                g_print("\r Channel 1 db0: %2.4f, Channel 2 db0: %2.4f", dB0l, dB0r);

                sumframes += rc;

        }

        g_print("-> Test Succeded \n");

        snd_pcm_close(AlsaCapture.capture_handle);

        free(AlsaCapture.buffer_alsa_capture);
        if(params->doFilter)
                free(eq_buffer);

        // Fixme delete eq

        return 0;
}

