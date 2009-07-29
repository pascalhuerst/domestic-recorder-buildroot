#include <stdio.h>
#include <alsa/asoundlib.h>
#include <glib.h>
#include <glib-object.h>
#include "../p0-alsa-tools.h"
#include "values.h"
#include "testplayback.h"
#include "testcapture.h"

#include <math.h>
#include <pthread.h>



static GThread* audio_playback_thread;

static gpointer audio_playback_loop_level(gpointer ptr)
{
        play_sinus(DEVICENAMEPLAYBACK, (test_params_t *) ptr);
        return NULL;
}

static void start_playback(test_params_t *ptr)
{
        audio_playback_thread = g_thread_create (audio_playback_loop_level,
                        ptr,
                        TRUE,
                        NULL);

        if (!audio_playback_thread)
                g_error("!!->Alsa: wow, audio thread create not possible\n");

        g_thread_set_priority(audio_playback_thread,
                              G_THREAD_PRIORITY_URGENT);

        usleep(1000*1000);

}


int main(int argc, char *argv[])
{

        test_params_t test_params;

        g_thread_init (NULL);
        g_type_init ();

        g_set_application_name ("Raumfeld Audio Test");

        oil_init();

        /***********************/
        /* test HW Clock first */
        /***********************/

        g_print("-> starting hwclock test with 0\n");


        p0_alsa_tools_open_hw_clock();
        p0_alsa_tools_write_hw_clock(0);

        double val0 = p0_alsa_tools_get_hw_clock_ppm(DEVICENAMEPLAYBACK);

        if(val0 > 44100)
                g_error("minimum speed is too fast: %2.6f, musn't be faster than %2.6f\n",
                        val0,
                        44100.0);


        g_print("-> starting hwclock test with 4095\n");

        p0_alsa_tools_write_hw_clock(4095);

        double val1 = p0_alsa_tools_get_hw_clock_ppm(DEVICENAMEPLAYBACK);

        if(val1 < 44100)
                g_error("maximum speed is too slow: %2.6f, musn't be slower than %2.6f\n",
                        val0,
                        44100.0);

        p0_alsa_tools_write_hw_clock(2048);

        /************************/
        /* test plain level     */
        /***********************/
        g_print("-> starting level test \n");

        test_params.Amplitude = 32767;
        test_params.Freq      = 2500;
        test_params.mute      = 0;
        test_params.maxDB     = MAXDB0;
        test_params.minDB     = MINDB0;
        test_params.doFilter  = FALSE;

        start_playback(&test_params);

        test_capture(DEVICENAMECAPTURE,&test_params);

        stop_sinus();

        g_thread_join(audio_playback_thread);
        /************************/
        /* test mute     */
        /***********************/
        g_print("-> starting silience test \n");

        test_params.Amplitude = 32767;
        test_params.Freq      = 2500;
        test_params.mute      = 1;
        test_params.maxDB     = MAXDB0SILENCE;
        test_params.minDB     = MINDB0SILENCE;
        test_params.doFilter  = FALSE;

        start_playback(&test_params);

        test_capture(DEVICENAMECAPTURE,&test_params);

        stop_sinus();

        g_thread_join(audio_playback_thread);

        /************************/
        /* test with filter high */
        /***********************/

        g_print("-> starting filter test with Amplitude %d \n", test_params.Amplitude);

        //20.0 *log10((float)AlsaCapture.max_l/32767.0);

        test_params.Amplitude = 32767; //pow(10.0, (-24.0 / 20.0)) * 32767.0;
        test_params.Freq      = 2500;
        test_params.mute      = 0;
        test_params.maxDB     = MAXDB0FILTERSILENCE;
        test_params.minDB     = MINDB0FILTERSILENCE;
        test_params.doFilter  = TRUE;

        start_playback(&test_params);

        test_capture(DEVICENAMECAPTURE,&test_params);

        stop_sinus();

        g_thread_join(audio_playback_thread);

        /************************/
        /* test with filter low */
        /***********************/


        g_print("-> starting filter test with Amplitude %d \n", test_params.Amplitude);

        test_params.Amplitude = 32767; //pow(10.0, (-24.0 / 20.0)) * 32767.0;
        test_params.Freq      = 440;
        test_params.mute      = 0;
        test_params.maxDB     = MAXDB0FILTERSILENCE;
        test_params.minDB     = MINDB0FILTERSILENCE;
        test_params.doFilter  = TRUE;

        start_playback(&test_params);

        test_capture(DEVICENAMECAPTURE,&test_params);

        stop_sinus();

        g_thread_join(audio_playback_thread);


        return 0;
}
