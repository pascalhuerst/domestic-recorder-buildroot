/*
 * P0Alsa:
 *
 * This class serves the UPnP backend for the P0 Alsa
 */

//#define ALSA_PCM_NEW_HW_PARAMS_API

#include <string.h>
#include <sys/time.h>
#include <alsa/asoundlib.h>
#include <libgupnp/gupnp.h>
#include <raumfeld/time.h>
#include <liboil/liboil.h>

#include "p0-renderer-types.h"
#include "options.h"
#include "p0-alsa.h"
#include "p0-alsa-tools.h"
#include "p0-alsa-capture.h"
#include "p0-dsp.h"
#include "p0-feedback.h"
#include "p0-streamserver.h"
#include "p0-eq.h"

/* general defines for playback */
//#define USETHREADS

#define NOVERBOSE					0
#define COOLVERBOSE					1
#define FULLVERBOSE					2

// set this define if you want to debug and step through the code
//#define ENABLEDEBUGGING
//#define INITIALTRIGGERSECOND         20
//#define NOSTRETCH
//#define USEBYTEBYBYTE

/* different streaming modes to set */
enum
{
        STREAMSTATE_INIT,
        STREAMSTATE_MUTING,
        STREAMSTATE_PREROLLING,
        STREAMSTATE_WAITFORPLAY,
        STREAMSTATE_WAITFORTRIGGER,
        STREAMSTATE_STREAMING,
        STREAMSTATE_STREAMENDING
};

static const char * stream_state_desc[7] = {
                "INITIALIZED   ",
                "STOPPED       ",
                "PREROLL       ",
                "WAITFORPLAY   ",
                "WAITFORTRIGGER",
                "PLAYBACK      ",
                "ENDOFSTREAM   " };


/* filter values definitions */
struct kalmanval
{
        int i;
        double x_next;
        double x;
        double P_next;
        double P;
        double K;
        double Q;
        double R;
        double z;
};

struct _P0Alsa
{

        GObject parent_instance;

        TimeClient* time_client;
        P0Feedback* feedback;

        snd_pcm_t* playback_handle;

        snd_pcm_hw_params_t* hwparams_playback;
        snd_pcm_sw_params_t* swparams_playback;

        snd_pcm_uframes_t frames_per_period;
        snd_pcm_uframes_t ringbufferframes;

        GThread* audio_playback_thread;

        guint buffer_in_size;
        guint buffer_in_write_pos;
        guint buffer_in_read_pos;
        guint next_trigger_frame;
        guint buffer_read_total_frames;

        volatile guint buffer_in_read_inc;
        volatile guint buffer_in_write_inc;

        long long int total_phase_offset_frames;
        double start_phase_offset_frames;

        gchar* buffer_in;
        gchar* buffer_alsa_playback;

        gboolean terminate_loop;
        gint stream_state;
        gboolean play_called;

        gboolean do_capture;

        GMutex* writeread_mutex;
        GCond* writeread_condition;

        P0Eq            *eq;
        gint32          *eq_buffer;
        EQParameters    eq_params;

        int tc_start_sec;

        int hw_clock_speed;
        gdouble hw_clock_max_per_sample;
        gdouble hw_clock_min_per_sample;

        struct kalmanval kalman_values;
};

static gchar *device_name_capture;
static gchar *device_name_playback;

/* Signals for communication with the rest of the world */
enum
{
        READY,
        PLAYSTATE_CHANGED,
        BUFFER_FILLED,
        ERROR_OCCURED,
        LAST_SIGNAL
};

static void p0_alsa_dispose(GObject *object);
static gpointer p0_alsa_audio_playback_loop(gpointer ptr);
static gboolean p0_alsa_audio_write(P0Alsa *alsa, gint framesread, gint frameswrite);
static long p0_alsa_wait_to_timecode(P0Alsa *alsa);
static void p0_alsa_init_kalman(struct kalmanval *s);

static long p0_alsa_wait_to_timecode(P0Alsa *alsa);
static void p0_alsa_init_kalman(struct kalmanval *s);
static double p0_alsa_dokalman(double f, struct kalmanval *s);

static void p0_alsa_ready(P0Alsa *alsa);
static void p0_alsa_buffer_filled(P0Alsa *alsa);
static void p0_alsa_playstate_changed(P0Alsa *alsa, PlayState new_state);
static void p0_alsa_error_occured(P0Alsa *alsa, const gchar *errorstring);

G_DEFINE_TYPE (P0Alsa, p0_alsa, G_TYPE_OBJECT)

static guint p0_alsa_signals[LAST_SIGNAL] = { 0 };

//
static void p0_alsa_class_init(P0AlsaClass* klass)
{
        GObjectClass* object_class = G_OBJECT_CLASS (klass);

        p0_alsa_signals[READY] = g_signal_new("ready",
                                              G_TYPE_FROM_CLASS (klass),
                                              G_SIGNAL_RUN_FIRST,
                                              G_STRUCT_OFFSET (P0AlsaClass, ready),
                                              NULL,
                                              NULL,
                                              g_cclosure_marshal_VOID__VOID,
                                              G_TYPE_NONE,
                                              0,
                                              G_TYPE_NONE);

        p0_alsa_signals[PLAYSTATE_CHANGED] = g_signal_new("playstate-changed",
                                                          G_TYPE_FROM_CLASS (klass),
                                                          G_SIGNAL_RUN_FIRST,
                                                          G_STRUCT_OFFSET (P0AlsaClass, play_state_changed),
                                                          NULL,
                                                          NULL,
                                                          g_cclosure_marshal_VOID__INT,
                                                          G_TYPE_NONE,
                                                          1,
                                                          G_TYPE_INT);

        p0_alsa_signals[BUFFER_FILLED] = g_signal_new("buffer-filled",
                                                      G_TYPE_FROM_CLASS (klass),
                                                      G_SIGNAL_RUN_FIRST,
                                                      G_STRUCT_OFFSET (P0AlsaClass, buffer_filled),
                                                      NULL,
                                                      NULL,
                                                      g_cclosure_marshal_VOID__VOID,
                                                      G_TYPE_NONE,
                                                      0,
                                                      G_TYPE_NONE);

        p0_alsa_signals[ERROR_OCCURED] = g_signal_new("error-occured",
                                                      G_TYPE_FROM_CLASS (klass),
                                                      G_SIGNAL_RUN_FIRST,
                                                      G_STRUCT_OFFSET (P0AlsaClass, error_occured),
                                                      NULL,
                                                      NULL,
                                                      g_cclosure_marshal_VOID__STRING,
                                                      G_TYPE_NONE,
                                                      1,
                                                      G_TYPE_STRING);

        object_class->dispose = p0_alsa_dispose;
}

P0Alsa*
p0_alsa_new(TimeClient *time_client,
            const gchar *device_name_playback_param,
            const gchar *device_name_capture_param,
            P0Feedback *feedback)
{
        P0Alsa* alsa;

        g_return_val_if_fail (TIME_IS_CLIENT (time_client), NULL);
        g_return_val_if_fail (IS_P0_FEEDBACK (feedback), NULL);

        device_name_playback = device_name_playback_param ? g_strdup(device_name_playback_param) : g_strdup("default");

        device_name_capture = device_name_capture_param ? g_strdup(device_name_capture_param) : NULL;

        alsa = g_object_new(TYPE_P0_ALSA,
                            NULL);

        alsa->time_client = g_object_ref(time_client);

        time_client_set_verbose(alsa->time_client,
                                options_get_verbose() == FULLVERBOSE);
        time_client_run(alsa->time_client);

        alsa->feedback = g_object_ref(feedback);

        return alsa;
}

static void p0_alsa_init(P0Alsa* alsa)
{
        alsa->terminate_loop = FALSE;

        /* allocate the mutex stuff */
        alsa->writeread_mutex = g_mutex_new();

        alsa->writeread_condition = g_cond_new();

        // init HW Clock Control
        if (options_get_hwclock())
        {
                g_print("->Alsa: initializing HW CLOCK control \n");

                p0_alsa_tools_open_hw_clock();
                alsa->hw_clock_speed = 0;
                p0_alsa_tools_write_hw_clock(alsa->hw_clock_speed);

                double val0 = p0_alsa_tools_get_hw_clock_ppm(device_name_playback);

                alsa->hw_clock_speed = 4095;

                p0_alsa_tools_write_hw_clock(alsa->hw_clock_speed);

                double val1 = p0_alsa_tools_get_hw_clock_ppm(device_name_playback);

                alsa->hw_clock_max_per_sample = (val1 - SAMPLERATE) / ((double) SAMPLERATE);
                alsa->hw_clock_min_per_sample = (val0 - SAMPLERATE) / ((double) SAMPLERATE);

                g_print("->Alsa: min: %2.6f, max %2.6f\n",
                        alsa->hw_clock_min_per_sample,
                        alsa->hw_clock_max_per_sample);

                alsa->hw_clock_speed = 2048;

                p0_alsa_tools_write_hw_clock(alsa->hw_clock_speed);

        }

        /* Allocate a hardware parameters object */
        snd_pcm_hw_params_alloca(&(alsa->hwparams_playback));

        snd_pcm_sw_params_alloca(&(alsa->swparams_playback));

        /* initialize alsa */
        if (p0_alsa_tools_set_playback_params(device_name_playback,
                                              &alsa->playback_handle,
                                              alsa->hwparams_playback,
                                              alsa->swparams_playback,
                                              &alsa->frames_per_period,
                                              &alsa->ringbufferframes) < 0)
                return;

        if (device_name_capture != NULL)
                alsa->do_capture = TRUE;
        else
                alsa->do_capture = FALSE;

        if (alsa->do_capture)
                p0_alsa_audio_capture_init(device_name_capture);

        int ringbuffersize = alsa->ringbufferframes * BYTESPERFRAME;

        alsa->buffer_alsa_playback = (char*) malloc(ringbuffersize);

        memset(alsa->buffer_alsa_playback,
               0,
               ringbuffersize);

        alsa->buffer_in_size = JITTERDIST * BYTESPERFRAME;

        alsa->buffer_in = (char *) malloc(alsa->buffer_in_size);

        memset(alsa->buffer_in,
               0,
               alsa->buffer_in_size);

        alsa->buffer_in_read_pos = 0;

        alsa->buffer_in_write_pos = 0;

        alsa->buffer_in_write_inc = 0;

        alsa->buffer_in_read_inc = 0;

        alsa->next_trigger_frame = 0;

        oil_init();

        alsa->eq = p0_eq_new(SAMPLERATE,ZP_STEREO,ZP_TYPE_INT32 );

        alsa->eq_buffer = (gint32*) malloc(alsa->ringbufferframes * 2 * sizeof (gint32) );

        p0_eq_getparams(alsa->eq, &alsa->eq_params);

        alsa->eq_params.Filter1Mode = SHELVING;
        alsa->eq_params.fFilter1MidFreq = 400;
        alsa->eq_params.fFilter1Q = 0.2;
        alsa->eq_params.fFilter1Gain = 0;

        alsa->eq_params.fFilter2MidFreq = 2500;
        alsa->eq_params.fFilter2Q = 0.2;
        alsa->eq_params.fFilter2Gain = 0;
        alsa->eq_params.Filter3Mode = SHELVING;
        alsa->eq_params.fFilter3MidFreq = 5000;
        alsa->eq_params.fFilter3Q = 0.2;
        alsa->eq_params.fFilter3Gain = 0;

        p0_eq_setparams(alsa->eq, &alsa->eq_params);


}

/*******************************************************************************
 * MAIN LOOP FUNCTION
 *******************************************************************************/

static gpointer p0_alsa_audio_playback_loop(gpointer ptr)
{
        /* FIXME: the names should be more read friendly */
        /* FIXME: check longs + ints */

        P0Alsa *alsa = ptr;

        int prefill_frames;
        int stretch_frames;
        int num_periods;
        int wait_for_time = 8;
        int ping_frames_offset;

        int samplep;
        int inc_frames;

        double lplayback_frames;
        double average_diff_per_frames;
        double old_diff;
        float r_float;

        double mid_value_hw = 0.0;

        g_return_val_if_fail (IS_P0_ALSA (alsa),NULL);

        /************ Prefilling ***********************
         * just for one period to lower ringbufferdrift
         * error in prefilltime which is one of the more
         * complicated problems when it's about syncing
         * **********************************************/

        if (alsa->stream_state != STREAMSTATE_INIT)
                g_error("->Alsa: we alrady have started streaming? did not even prefilled the alsa buffer!\n");

        prefill_frames = ALSAJITTERBUFLEN; //alsa->ringbufferframes;

        p0_alsa_audio_write(alsa,
                            prefill_frames,
                            prefill_frames);

        samplep = prefill_frames;

        /* now wait for the timecode */
        g_print("->Alsa: waiting for time-server ");

        while (--wait_for_time)
        {
                struct timeval temp;

                g_print(".");

                usleep(500000);

                if (time_client_get_time(alsa->time_client,
                                         &temp) == TIMEOK)
                {
                        alsa->tc_start_sec = temp.tv_sec + 2;

                        g_print("\n->Alsa: alsa prefill done, waiting for wallclock timecode %2d:00 to start\n",
                                alsa->tc_start_sec);
                        break;
                }
        }

        if (wait_for_time == 0)
                g_error("!!!->Alsa: no Timecode received. Is the TimeServer running?\n");

        /************ Startsync + start *****************
         * Now we wait for the startime
         * Currently this value is fixed
         * this means the clients have
         * to be started before the server
         * FIXME: this must also work with if the renderer
         * is turned on after the wallclock timeserver
         **************************************************/

        {
                long start_call_offset;

                start_call_offset = p0_alsa_wait_to_timecode(alsa);

                /* check whether the application is closing */
                if (alsa->terminate_loop)
                        return NULL;

                if (start_call_offset < 0)
                        g_error("->Alsa: negative return on start_call\n");

                g_print("->Alsa: started with offset: %ld\n",
                        start_call_offset);

                /* Start the alsa device */
                int err = snd_pcm_start(alsa->playback_handle);

                if (err < 0)
                        g_error("!!->Alsa: Start error: %s\n",
                                        snd_strerror(err));

                /* announce that we are ready */
                p0_alsa_ready(alsa);
        }

        /* Init all values */
        p0_alsa_init_kalman(&alsa->kalman_values);

        lplayback_frames = 0;

        stretch_frames = 0;

        inc_frames = 0;

        r_float = 0.0;

        stretch_frames = 0;

        num_periods = 0;

        average_diff_per_frames = 1.0;

        old_diff = 0;

        alsa->buffer_read_total_frames = 0;

        alsa->start_phase_offset_frames = 0;

        /* calculate the estimated ping time in samples */
        ping_frames_offset = 0;//time_client_getoffset(alsa->time_client) * 10 / 441;

        /* find out the current phase offset,
         * this value is used when a new stream trigger time is calculated*/

        /* initially we started with one empty alsaringbuffer as a prefill
         * this has to be be compensated now */
        //alsa->total_phase_offset_frames = -alsa->ringbufferframes;
        alsa->total_phase_offset_frames = 0;

        /* now add the estimated ping time at the beginning of the
         * playback to the absolute position This means that every
         * change in the ping time is part of the drift calculation
         * which could lead to problems if the first ping value is not
         * appropriate FIXME: Think about this problem.... */
        alsa->total_phase_offset_frames += -ping_frames_offset;

        /* I have to set myself a time to start */
#ifdef INITIALTRIGGERSECOND

        char stemp[64];
        snprintf (stemp, sizeof (stemp), "%d:00", INITIALTRIGGERSECOND);
        p0_alsa_set_next_trigger_time (alsa, stemp);
#endif

        int lockcnt = (options_get_start_transient() * SAMPLERATE) / alsa->frames_per_period;

        /* let's go */

        while (!alsa->terminate_loop)
        {

                /* wait */

                int pdiff = p0_alsa_tools_get_delay(alsa->playback_handle);

                //                g_print("pdiff: %d     \n",pdiff);


                while (TRUE)
                {
                        if (pdiff >= ALSAJITTERBUFLEN)
                        {

#ifdef USETHREADS
                                g_mutex_lock (alsa->writeread_mutex);

                                g_cond_broadcast(alsa->writeread_condition);

                                g_mutex_unlock (alsa->writeread_mutex);
#endif
                                usleep(ALSASLEEPTIME);

                                pdiff = p0_alsa_tools_get_delay(alsa->playback_handle);
                        } else
                                break;
                }

                struct timeval tctimestamp;
                struct timeval tctimestart;
                double sfac;

                /* find out alsa's position where  */
                lplayback_frames = samplep - p0_alsa_tools_get_delay(alsa->playback_handle);

                /* get the wallcock server time */
                time_client_get_time(alsa->time_client,
                                     &tctimestamp);

                sfac = time_client_getspeedfac(alsa->time_client);
                /* now calculate the delta between the wallcock time
                 * when the soundcard (should have started) started
                 * (which is a fixed value right now) and the current
                 * wallclock time
                 */

                tctimestart.tv_sec = alsa->tc_start_sec;
                tctimestart.tv_usec = 0;

                long long int wallclock_delta = time_diff(&tctimestamp,
                                                          &tctimestart);

                if (wallclock_delta < 0)
                {
                        g_error("\n!!->Alsa: timediff < 0");

                }

                /* now calculate the desired position in frames */
                double sollpos_wc_frames = ((double) wallclock_delta * (44.1 / 1000.0));

                stretch_frames = 0;

                /* in the first loop we will try to find out hte start offset
                 */
                if (!num_periods)
                {
                        if (!lplayback_frames)
                                g_error("\n Soundcard does not start playback!");

                        alsa->start_phase_offset_frames = sollpos_wc_frames - lplayback_frames;

                        alsa->total_phase_offset_frames -= alsa->start_phase_offset_frames;

                }

                double wc_to_sc_drift_fact = (double) sollpos_wc_frames / (lplayback_frames + alsa->start_phase_offset_frames);

                double unfiltered_diff = sollpos_wc_frames - (lplayback_frames + alsa->start_phase_offset_frames + inc_frames);

                double diff = 0;

                /* For safety reasons we have to calcualte minimum and maximum limits */

                double max;
                double min;

                max = alsa->frames_per_period / 16;
                min = -1.0 * (alsa->frames_per_period / 16);

                average_diff_per_frames = (wc_to_sc_drift_fact * (float) alsa->frames_per_period) - (alsa->frames_per_period);
                // the first few seconds we are going to have a light lowpass filter

                static double lx;

                /* in the first x seconds we have to react fast */
                if (num_periods < lockcnt)
                {
                        alsa->kalman_values.x = average_diff_per_frames;

                        diff = unfiltered_diff;

                } else
                /* the result of filter can only correct errors very slowly */
                {
                        if (num_periods == lockcnt)
                                /* tell the happy news to the world */
                                g_print("->Alsa: **********Synclock!**********\n\n");

                        if (options_get_hwclock())
                        {

                                /* We are using the Raumfeld variable hw clock system instead of resampling */

                                double max_catchup = (alsa->hw_clock_max_per_sample) * (double) alsa->frames_per_period; //4095
                                double min_catchup = (alsa->hw_clock_min_per_sample) * (double) alsa->frames_per_period; // 0

                                if (unfiltered_diff >= max_catchup)
                                        alsa->hw_clock_speed = 4095;
                                else
                                        if (unfiltered_diff <= min_catchup)
                                                alsa->hw_clock_speed = 0;
                                        else
                                        {
                                                alsa->hw_clock_speed = 2048;
                                        }

                                p0_alsa_tools_write_hw_clock(alsa->hw_clock_speed);

                                //unfiltered_diff
                                /*
                                 hw_clock_speed
                                 hw_clock_max
                                 */
                                //				g_print("diff: max %2.10f min %2.10f diff:%2.4f hwclock %d\n", max_catchup,min_catchup,unfiltered_diff,alsa->hw_clock_speed);


                                /* of hw clock*/
                        } else
                        {
                                if (num_periods < lockcnt * 4)
                                {

                                        diff = p0_alsa_dokalman(diff,
                                                                &alsa->kalman_values);
                                        lx = average_diff_per_frames;
#ifdef NOSTRETCH
                                        diff = 0;
#endif
                                } else
                                {
                                        if (lockcnt == num_periods)
                                                /* tell the happy news to the world */
                                                g_print("->Alsa: **********Synclock 2 !**********\n\n");

                                        // bug lowpass filter
#define SLPF 0.9999
                                        diff = lx;
                                        lx = (lx * SLPF + unfiltered_diff * (1.0 - SLPF)) * 0.95 + average_diff_per_frames * 0.05;
#ifdef NOSTRETCH

#endif
                                }

                        }

                }

                /* check whether we are out of lock */
                if ((diff > OUTOFLOCKDELTA || diff < -OUTOFLOCKDELTA) && num_periods > lockcnt)
                {
#ifdef ENABLEDEBUGGING
                        g_print("!!!->Alsa: out of lock!\n");
#else
                        g_error("->Alsa: out of lock!");
#endif
                }

                /* now make sure that drift compensation is in the rage of our buffers and ears */
                float act_stretch_frames;

                if (diff > max)
                        act_stretch_frames = max;
                else
                        if (diff < min)
                                act_stretch_frames = min;
                        else
                                act_stretch_frames = diff;

                /* we have to calculate way more acurate as frames, so
                 * we have to store the carry over (Uebertrag) from
                 * loop to loop. This uebertrag is stored in r_float.
                 */

                stretch_frames = act_stretch_frames + r_float;

                /* if the uebertrag is bigger than one it we have to reduce it */
                if (r_float > 1.0)
                        r_float -= 1.0;

                r_float += act_stretch_frames - (float) stretch_frames;

                /* for old compatibility reasons we have to swap stretch frames */
                stretch_frames = -stretch_frames;

                inc_frames -= stretch_frames;

                /* calculate flutter */

                /* debug out */
                /* FIXME: caculate PPM! */
                /* FIXME: \033 for escape character */

                old_diff = diff;

                num_periods++;

                /* now write it to the alsa card */
                p0_alsa_audio_write(alsa,
                                    alsa->frames_per_period - stretch_frames,
                                    alsa->frames_per_period);

                samplep += alsa->frames_per_period;

                int playback_max_l = 0;
                int playback_max_r = 0;
                int capture_max_l = 0;
                int capture_max_r = 0;

                p0_dsp_get_minmax((short *) (alsa->buffer_alsa_playback),
                                  alsa->frames_per_period,
                                  &playback_max_l,
                                  &playback_max_r);

                if (alsa->do_capture)
                        p0_alsa_audio_capture_get_minmax(&capture_max_l,
                                                         &capture_max_r);

                p0_feedback_set_levels(alsa->feedback,
                                       playback_max_l,
                                       playback_max_r,
                                       capture_max_l,
                                       capture_max_r);

                int act_ping = time_client_getoffset(alsa->time_client) * 10 / 441;
#ifndef USEBYTEBYBYTE

                if (options_get_verbose() == FULLVERBOSE && !options_get_hwclock())
                {
                        g_print("pf: %.1f swc: %.1f sctowc:%1.10f sfac:%1.10f, d2: %3.1f phaseoff: %.1f diff:%+2.5f oDiff:%+2.5f sF:%4d avr: %+2.7f pf:%3d  pfnow:%3d incFrames:%d \r",
                                lplayback_frames + alsa->start_phase_offset_frames,
                                sollpos_wc_frames,
                                wc_to_sc_drift_fact,
                                sfac,
                                lplayback_frames + alsa->start_phase_offset_frames - sollpos_wc_frames,
                                alsa->start_phase_offset_frames,
                                diff,
                                unfiltered_diff,
                                stretch_frames,
                                average_diff_per_frames,
                                ping_frames_offset,
                                act_ping,
                                inc_frames);
                } else
                        if (options_get_verbose() == FULLVERBOSE && options_get_hwclock())
                        {
                                g_print("pf: %.1f oDiff:%+3.5f mid:%+3.5f speed: %d pf:%3d  pfnow:%3d \r",
                                        lplayback_frames + alsa->start_phase_offset_frames,
                                        unfiltered_diff,
                                        mid_value_hw,
                                        alsa->hw_clock_speed,
                                        ping_frames_offset,
                                        act_ping);
                        } else
                                if (options_get_verbose() == COOLVERBOSE)
                                {

                                        char outputl[17];
                                        char outputr[17];
                                        char inputl[17];
                                        char inputr[17];

                                        int k;

                                        for (k = 0; k < 16; k++)
                                        {
                                                outputl[k] = playback_max_l > k * 2048 ? 'O' : ' ';
                                                outputr[k] = playback_max_r > k * 2048 ? 'O' : ' ';
                                                inputl[k] = capture_max_l > k * 2048 ? 'O' : ' ';
                                                inputr[k] = capture_max_r > k * 2048 ? 'O' : ' ';

                                        }
                                        outputl[k] = 0;
                                        outputr[k] = 0;
                                        inputl[k] = 0;
                                        inputr[k] = 0;

                                        char fillstate[128];

                                        if (alsa->stream_state >= STREAMSTATE_STREAMING)
                                        {
                                                int dist = alsa->buffer_in_write_inc - alsa->buffer_in_read_inc;

                                                sprintf(fillstate,
                                                        "%d%% %dms",
                                                        dist * 100 / JITTERDIST,
                                                        dist * 1000 / SAMPLERATE);
                                        } else
                                                sprintf(fillstate,
                                                        "---");

                                        if (alsa->do_capture)
                                                g_print("->Alsa:%s PL:%s  PR:%s CL:%s  CR:%s Sync:%+3.2f Fill: %s        \r",
                                                        stream_state_desc[alsa->stream_state],
                                                        outputl,
                                                        outputr,
                                                        inputl,
                                                        inputr,
                                                        unfiltered_diff,
                                                        fillstate);
                                        else
                                                g_print("->Alsa:%s L:%s  R:%s Sync:%+3.2f Fill:%s           \r",
                                                        stream_state_desc[alsa->stream_state],
                                                        outputl,
                                                        outputr,
                                                        unfiltered_diff,
                                                        fillstate);

                                }

                //#ifndef P0ARMWORKAROUND
                /*
                 FILE *f;

                 f=fopen("test.dat","a+");

                 fprintf(f,"%d %.4f %.4f %d\n",num_periods,diff,unfiltered_diff,act_ping);

                 fclose(f);
                 */
                //#endif

#endif

        }

        return NULL;
}

static void p0_alsa_init_kalman(struct kalmanval* s)
{
        s->i = 0;
        s->x = 0.0;
        s->P = 1;
        s->i = 0;

        s->Q = 1.0 / 1000000;
        s->R = 10000;

}
;

static double p0_alsa_dokalman(double f, struct kalmanval *s)
{

        s->z = f;
        s->x_next = s->x;
        s->P_next = s->P + s->Q;
        s->K = s->P_next / (s->P_next + s->R);
        s->x = s->x_next + s->K * (s->z - s->x_next);
        s->P = (1 - s->K) * s->P_next;

        s->i++;

        return s->x;
}

static gboolean p0_alsa_audio_write(P0Alsa *alsa, gint framesread, gint frameswrite)
{
        int rc;
        int inc_frames_read;
        int inc_frames_write;
        int step_frames;
        int frames_diff;
        int add_frames;
        short *src_left;
        short *src_right;
        short *dest_left;
        short *dest_right;

        inc_frames_read = 0;
        inc_frames_write = 0;
        add_frames = 0;

        int i;

        /* check for heavy underuns */
        if (alsa->stream_state >= STREAMSTATE_STREAMING && alsa->buffer_in_read_inc > alsa->buffer_in_write_inc)
        {
                g_print("!!->Alsa: Streaming underrun detected by audiowrite loop!: read: %d write: %d\n",
                        alsa->buffer_in_read_inc,
                        alsa->buffer_in_write_inc);
                /* tell the outside world we have stopped */

                /* streamstate will be changed in this function*/
                p0_alsa_stop_stream(alsa);
                p0_alsa_playstate_changed(alsa,
                                          STOPPED);
                p0_alsa_error_occured(alsa,
                                      "stream buffer underrun");
        }

        /* warn before for debug */
        if (alsa->stream_state == STREAMSTATE_STREAMING && alsa->buffer_in_read_inc + STARTJITTERDIST / 2 > alsa->buffer_in_write_inc)
                g_print("->Alsa: ohoh jitter buffer getting low: read: %d write: %d\n",
                        alsa->buffer_in_read_inc,
                        alsa->buffer_in_write_inc);

        //        g_mutex_lock (alsa->writeread_mutex);

        if (alsa->stream_state < STREAMSTATE_WAITFORTRIGGER)
        {

                /* this is easy we just fill it with 0....*/
                memset(alsa->buffer_alsa_playback,
                       0,
                       frameswrite * BYTESPERFRAME);

                alsa->buffer_read_total_frames += framesread;

        } else
        {

                /* now we read from the input_buffer, which is a quite big jitter ring buffer */
                /* beware: most of the pointers and calculations is done in bytes !!*/

                src_left = (short *) (alsa->buffer_in + alsa->buffer_in_read_pos);
                src_right = ((short *) (alsa->buffer_in + alsa->buffer_in_read_pos)) + 1;

                dest_left = (short *) (alsa->buffer_alsa_playback);
                dest_right = (short *) (alsa->buffer_alsa_playback) + 1;

                /* this means we have to insert data */
                if (framesread <= frameswrite)
                        frames_diff = frameswrite - framesread;
                else
                        /* this means we have to skip data */
                        frames_diff = framesread - frameswrite;

                /* also here we just fill the buffer with 0 first FIXME: Is this necessary?*/
                if (frames_diff)
                        memset(alsa->buffer_alsa_playback,
                               0,
                               frameswrite * BYTESPERFRAME);

                /* now calculate where to insert or skip the data*/
                if (frames_diff)
                        step_frames = framesread / (frames_diff);
                else
                        step_frames = 0;
                {
                        /* make sure the whole buffer get's always filled */
                        /* FIXME: Here are to many counters for a sample loop! */
                        while (inc_frames_write < frameswrite)
                        {

                                if (alsa->buffer_read_total_frames >= alsa->next_trigger_frame)
                                {

                                        *dest_left = *src_left;
                                        *dest_right = *src_right;

                                        src_left += 2;
                                        src_right += 2;

                                        /* FIXME: don't do this for every sample!! */
                                        /* Beware: streamstate could have changed in anotehr thread! */
                                        if (alsa->stream_state == STREAMSTATE_WAITFORTRIGGER)
                                        {
                                                alsa->stream_state = STREAMSTATE_STREAMING;

                                                g_print("->Alsa: playback start!\n");

                                                if (alsa->buffer_read_total_frames == alsa->next_trigger_frame)
                                                        g_print("->Alsa: Trigger Hit at:%d start playing\n",
                                                                alsa->buffer_read_total_frames);

                                                if (alsa->buffer_read_total_frames > alsa->next_trigger_frame)
                                                        g_print("!!->Alsa: Trigger Point MISSED: %d, we are at %d, offset is %lld ++++++++++++++++++++++++\n",
                                                                alsa->next_trigger_frame,
                                                                alsa->buffer_read_total_frames,
                                                                alsa->total_phase_offset_frames);

                                                p0_alsa_playstate_changed(alsa,
                                                                          PLAYING);
                                        }

                                        add_frames++;

                                } else
                                {

                                        *dest_left = 0;
                                        *dest_right = 0;

                                }

                                inc_frames_write++;

                                inc_frames_read++;

                                alsa->buffer_read_total_frames++;

                                dest_left += 2;
                                dest_right += 2;

                                if (framesread > frameswrite && !(inc_frames_read % step_frames))
                                {
                                        /* now we have to skip one sample */
                                        src_left += 2;
                                        src_right += 2;

                                        inc_frames_read++;

                                        /* FIXME: Theoreticlly this can be a problem, if the triggertime is exactly the one which is skipped */
                                        alsa->buffer_read_total_frames++;
                                        add_frames++;
                                }

                                /* check streaming ringbuffer end, beware of >=!! */
                                if ((char *) src_left >= alsa->buffer_in + alsa->buffer_in_size)
                                {

                                        src_left = (short *) (alsa->buffer_in);
                                        src_right = ((short *) alsa->buffer_in) + 1;
                                }

                                /* simple linear interpolation */
                                if (frameswrite > framesread && !(inc_frames_read % step_frames))
                                {

                                        int ins = *(dest_left - 2);

                                        ins += *src_left;
                                        ins = ins / 2;

                                        *dest_left = (short) ins;

                                        ins = *(dest_right - 2);
                                        ins += *src_right;
                                        ins = ins / 2;

                                        *dest_right = (short) ins;

                                        dest_left += 2;
                                        dest_right += 2;

                                        inc_frames_write++;
                                }

                        } /* of while */

                        /* now we have to check whether the last one of this buffer is the one which is skipped
                         * In this case we have to increase our counters by one */
                        if (framesread > frameswrite && !((inc_frames_read + 1) % step_frames))
                        {
                                inc_frames_read++;
                                alsa->buffer_read_total_frames++;
                                add_frames++;
                        }
                }
        } /* of else alsa->stream_state< STREAMSTATE_STREAMING */

        //        g_mutex_unlock (alsa->writeread_mutex);

        /* calculate eq */
        oil_conv_s32_s16(alsa->eq_buffer,
                         sizeof(gint32),
                         (short *) alsa->buffer_alsa_playback,
                         sizeof(short),
                         frameswrite * 2);

        for(i=0; i < frameswrite * 2; i++)
        {
                alsa->eq_buffer[i] = alsa->eq_buffer[i]<<16;
        }
        p0_eq_process(alsa->eq, alsa->eq_buffer,frameswrite);
        for(i=0; i < frameswrite * 2; i++)
        {
                alsa->eq_buffer[i] = alsa->eq_buffer[i]>>16;
        }



        oil_clipconv_s16_s32((short *) alsa->buffer_alsa_playback,
                             sizeof(short),
                             alsa->eq_buffer,
                             sizeof(gint32),
                             frameswrite * 2);

        /* write it to the soundcard */
        rc = snd_pcm_writei(alsa->playback_handle,
                            alsa->buffer_alsa_playback,
                            frameswrite);

        if (rc != frameswrite)
        {
                /* FIXME: do something more intelligent here */
                if (rc == -EPIPE)
                {
#ifdef ENABLEDEBUGGING
                        g_print("!!->Alsa: Alsa underrun ?? i'm just muting...!\n");
#else
                        g_error("!!->Alsa: Alsa underrun ?? i'm just muting...!\n");
#endif

                        rc = snd_pcm_recover(alsa->playback_handle,
                                             rc,
                                             0);

                        if (rc == 0)
                        {
                                g_print("!!->Alsa: Could recover from alsa underrun!\n");
                        }
                } else
                        if (rc == -ESTRPIPE)
#ifdef ENABLEDEBUGGING
                                g_print("!!->Alsa: Alsa suspended!\n");
#else
                                g_error("!!->Alsa suspended\n");
#endif

                return FALSE;
        }

        /* now increase the values for the other thread */
        if (alsa->stream_state >= STREAMSTATE_STREAMING)
        {

                alsa->buffer_in_read_inc += add_frames * BYTESPERFRAME;

                /* FIXME: what happens if the other starts in between these two statements ?   */

                /* check ringbuffer */
                if (alsa->buffer_in_read_pos + (add_frames * BYTESPERFRAME) < alsa->buffer_in_size)
                        alsa->buffer_in_read_pos += add_frames * BYTESPERFRAME;
                else
                        alsa->buffer_in_read_pos += (add_frames * BYTESPERFRAME) - alsa->buffer_in_size;

                /* this is just a safety check */
                if (add_frames != framesread)
                        g_print("!!->Alsa: framesread != add_frames!!!n\n\n");

                /* we reached the end of a stream ...*/
                if (alsa->stream_state == STREAMSTATE_STREAMENDING && alsa->buffer_in_read_inc >= alsa->buffer_in_write_inc)
                {

                        g_print("->Alsa: end of stream reached\n");

                        p0_alsa_stop_stream(alsa);

                        p0_alsa_playstate_changed(alsa,
                                                  STOPPED);

                }

        }

        return TRUE;
}

void p0_alsa_stop_stream(P0Alsa *alsa)
{
        g_return_if_fail (IS_P0_ALSA (alsa));

#ifndef USETHREADS
        g_mutex_lock (alsa->writeread_mutex);
#endif

        alsa->stream_state = STREAMSTATE_MUTING;

        alsa->play_called = 0;

        alsa->buffer_in_read_pos = 0;

        alsa->buffer_in_write_pos = 0;

        alsa->buffer_in_write_inc = 0;

        alsa->buffer_in_read_inc = 0;

#ifndef USETHREADS
        g_mutex_unlock (alsa->writeread_mutex);
#endif

        /* FIXME: make fadeout */
}

void p0_alsa_notify_stream_incoming(P0Alsa *alsa)
{
        if (alsa->stream_state <= STREAMSTATE_PREROLLING)
        {
                g_print("->Alsa: streamstate set to PREROLLING\n");

                p0_alsa_stop_stream(alsa);

                alsa->stream_state = STREAMSTATE_PREROLLING;

        } else
        {
                g_print("->Alsa: streamstate set to PREROLLING\n");

                p0_alsa_stop_stream(alsa);

                alsa->stream_state = STREAMSTATE_PREROLLING;

                g_print("->!!!!!!!Alsa: somebody wants to preroll while not stopped??\n");
        }

        return;
}

void p0_alsa_notify_end_stream(P0Alsa *alsa)
{
        g_return_if_fail (IS_P0_ALSA (alsa));

        g_print("->Alsa: notified: end of stream\n");

        alsa->stream_state = STREAMSTATE_STREAMENDING;
}

void p0_alsa_notify_play_pressed(P0Alsa *alsa)
{
        g_return_if_fail (IS_P0_ALSA (alsa));

        g_print("->Alsa: notified: play pressed\n");

        alsa->play_called = TRUE;

        if (alsa->stream_state == STREAMSTATE_WAITFORPLAY)
        {
                alsa->stream_state = STREAMSTATE_WAITFORTRIGGER;
                g_print("->Alsa: stream state changed to wait for trigger\n");
        }
}

static void p0_alsa_dispose(GObject *object)
{
        P0Alsa *alsa = P0_ALSA (object);

        /* Stop the loopback thread */
        alsa->terminate_loop = TRUE;

        g_thread_join(alsa->audio_playback_thread);

        if (alsa->do_capture)
                p0_alsa_audio_capture_exit();

        snd_pcm_drain(alsa->playback_handle);
        snd_pcm_close(alsa->playback_handle);

        free(alsa->buffer_alsa_playback);

        free(alsa->buffer_in);

        if (device_name_capture)
                g_free(device_name_capture);

        if (device_name_playback)
                g_free(device_name_playback);

        g_object_unref(alsa->time_client);
        g_object_unref(alsa->feedback);

        if (options_get_hwclock())
        {
                p0_alsa_tools_close_hw_clock();
        }

        G_OBJECT_CLASS (p0_alsa_parent_class)->dispose(object);

}

void p0_alsa_run(P0Alsa *alsa)
{
        g_return_if_fail (IS_P0_ALSA (alsa));
        g_return_if_fail (alsa->audio_playback_thread == NULL);

        /* create my main audio loop thread */
        alsa->audio_playback_thread = g_thread_create (p0_alsa_audio_playback_loop,
                        alsa,
                        TRUE,
                        NULL);

        if (!alsa->audio_playback_thread)
                g_error("!!->Alsa: wow, audio thread create not possible\n");

        g_thread_set_priority(alsa->audio_playback_thread,
                              G_THREAD_PRIORITY_URGENT);

}

void p0_alsa_handover_data(P0Alsa *alsa, guint buffer_length, gpointer buffer)
{

        int tocopy = buffer_length;
        int srcinc = 0;

        g_return_if_fail (IS_P0_ALSA (alsa));

        /* streaming data has to be copied so alsa can access it
         * also this thread is blocking to wait for alsa to
         * playback the audio data */

        /* check some basics */

        /* did somebody close the app ?*/
        if (alsa->terminate_loop)
                return;

        if (alsa->stream_state < STREAMSTATE_PREROLLING)
        {
                g_print("!!->Alsa: alsa gets streaming data, but alsa is not in prerolling or playing mode\n");
                return;
        }

        if (buffer_length >= alsa->buffer_in_size)
        {
                g_print("!!->Alsa: problem: buffer_length>=buffer_in_size");
        }

        if (alsa->stream_state < STREAMSTATE_WAITFORTRIGGER && !alsa->buffer_in_write_inc)
        {
                g_print("->Alsa: start stream prefilling....\n");
        }

        if (alsa->buffer_in_read_inc > alsa->buffer_in_write_inc)
        {
                g_print("!!->Alsa: Streaming underrun detected by handover!: read: %d write: %d\n",
                        alsa->buffer_in_read_inc,
                        alsa->buffer_in_write_inc);
#ifdef USETHREADS
                g_mutex_unlock (alsa->writeread_mutex);
#endif
                return;
        }

        /* start streaming if we have enaugh data */
#ifndef USETHREADS		// ifndef is correct!!
        g_mutex_lock(alsa->writeread_mutex);
#endif
        if (alsa->buffer_in_write_inc + tocopy - alsa->buffer_in_read_inc >= STARTJITTERDIST && alsa->stream_state < STREAMSTATE_WAITFORTRIGGER)
        {

                if (alsa->stream_state < STREAMSTATE_WAITFORPLAY)
                {
                        g_print("->Alsa: stream prefill finshed, wait for play\n");
                        p0_alsa_buffer_filled(alsa);
                }

                alsa->stream_state = STREAMSTATE_WAITFORPLAY;

                if (alsa->play_called)
                {
                        alsa->stream_state = STREAMSTATE_WAITFORTRIGGER;
                        g_print("->Alsa: stream prefill finshed, wait for trigger\n");
                }

        }
#ifndef USETHREADS
        g_mutex_unlock(alsa->writeread_mutex);
#endif

        /* check if we can write data to the buffer, block if necessary */
        while (TRUE)
        {
                if (alsa->buffer_in_write_inc + tocopy - alsa->buffer_in_read_inc >= JITTERDIST)
                {

                        /* did somebody close the app ?*/
                        if (alsa->terminate_loop)
                                return;

                        // has somebody pressed stop??
                        if (alsa->stream_state < STREAMSTATE_WAITFORPLAY)
                                return;

#ifndef USETHREADS
                        usleep(10* 1000 );
#else

                        g_mutex_lock (alsa->writeread_mutex);
                        GTimeVal timeout_val;

                        g_get_current_time(&timeout_val);

                        g_time_val_add(&timeout_val, 1000* 1000 );

                        // THIS LINE IS IMPORTANT!!! DONT TOUCH IT HENRY!!!
                        if(!g_cond_timed_wait(alsa->writeread_condition,alsa->writeread_mutex,&timeout_val))
                        g_error("!!->Alsa: Timeout on readloop!");

                        g_mutex_unlock (alsa->writeread_mutex);

#endif
                }
                else
                {
                        break;
                }
        }

        /* ok, we have enaugh space to copy the buffer */
        while (tocopy)
        {

                int copysize = alsa->buffer_in_size - alsa->buffer_in_write_pos;

                if (copysize > tocopy)
                copysize = tocopy;

                memcpy(alsa->buffer_in + alsa->buffer_in_write_pos,
                                buffer + srcinc, copysize);

                srcinc += copysize;

                tocopy -= copysize;

                alsa->buffer_in_write_pos += copysize;

                alsa->buffer_in_write_inc += copysize;

                if (alsa->buffer_in_write_pos == alsa->buffer_in_size)
                {
                        alsa->buffer_in_write_pos = 0;
                }

        }

        return;
}


static long p0_alsa_wait_to_timecode(P0Alsa *alsa)
{
        struct timeval p_tstamp;

        /************ Startsync + start **************/
        /* Now we wait for the startime
         * Currently this value is fixed
         * this means the clients have
         * to be started before the server
         *********************************************/

        while (TRUE)
        {
                if (alsa->terminate_loop)
                        return -1;

                if (time_client_get_time(alsa->time_client,
                                         &p_tstamp) == TIMEOK)
                {
                        if (p_tstamp.tv_sec >= alsa->tc_start_sec)
                                break;
                }

                usleep(1000);
        }

        return p_tstamp.tv_usec;
}

void p0_alsa_set_next_trigger_time(P0Alsa *alsa, const gchar *trigger_time)
{
        long sec;
        long usec;
        double offset;

        g_return_if_fail (IS_P0_ALSA (alsa));
        g_return_if_fail (trigger_time != NULL);

        /* FIXME: no buffer overflows please */
        sscanf(trigger_time,
               "%li:%li",
               &sec,
               &usec);

        offset = ((double) sec * SAMPLERATE + (double) SAMPLERATE / (1000 * 1000) * (double) usec);

        alsa->next_trigger_frame = ((int) offset - alsa->tc_start_sec * SAMPLERATE + alsa->total_phase_offset_frames);

        g_print("->Alsa: next trigger frame set to: %s %d, offset is: %lld\n",
                trigger_time,
                alsa->next_trigger_frame,
                alsa->total_phase_offset_frames);
}

void p0_alsa_get_punch_time(P0Alsa *alsa, struct timeval *clock_punch_time)
{

        time_client_get_time(alsa->time_client,
                             clock_punch_time);

        clock_punch_time->tv_sec += PUNCHDELTASEC;
}

static gboolean p0_alsa_emit_ready(P0Alsa *alsa)
{
        g_signal_emit(alsa,
                      p0_alsa_signals[READY],
                      0);

        return FALSE;
}

/* This function causes the "ready" signal to be emitted. But instead
 * of doing it directly, it uses a closure to emit it from an idle
 * handler in the main loop.
 */
static void p0_alsa_ready(P0Alsa *alsa)
{
        GSource *source;
        GClosure *closure;

        source = g_idle_source_new();
        g_source_set_priority(source,
                              G_PRIORITY_HIGH);
        closure = g_cclosure_new_object(G_CALLBACK (p0_alsa_emit_ready),
                                        G_OBJECT (alsa));
        g_source_set_closure(source,
                             closure);
        g_source_attach(source,
                        NULL);
        g_source_unref(source);
}

static gboolean p0_alsa_emit_buffer_filled(P0Alsa *alsa)
{
        g_signal_emit(alsa,
                      p0_alsa_signals[BUFFER_FILLED],
                      0);

        return FALSE;
}

/* This function causes the "buffer-filled" signal to be emitted. But
 * instead of doing it directly, it uses a closure to emit it from an
 * idle handler in the main loop.
 */
static void p0_alsa_buffer_filled(P0Alsa *alsa)
{
        GSource *source;
        GClosure *closure;

        source = g_idle_source_new();
        g_source_set_priority(source,
                              G_PRIORITY_HIGH);
        closure = g_cclosure_new_object(G_CALLBACK (p0_alsa_emit_buffer_filled),
                                        G_OBJECT (alsa));
        g_source_set_closure(source,
                             closure);
        g_source_attach(source,
                        NULL);
        g_source_unref(source);
}

typedef struct
{
        P0Alsa *alsa;
        PlayState state;
} P0AlsaPlaystateChangedData;

static void p0_alsa_playstate_changed_data_free(P0AlsaPlaystateChangedData *data)
{
        g_slice_free (P0AlsaPlaystateChangedData, data);
}

static gboolean p0_alsa_emit_playstate_changed(P0AlsaPlaystateChangedData *data)
{
        g_signal_emit(data->alsa,
                      p0_alsa_signals[PLAYSTATE_CHANGED],
                      0,
                      data->state);

        return FALSE;
}

/* This function causes the "playstate-changed" signal to be
 * emitted. But instead of doing it directly, it uses a closure to
 * emit it from an idle handler in the main loop.
 */
static void p0_alsa_playstate_changed(P0Alsa *alsa, PlayState new_state)
{
        P0AlsaPlaystateChangedData *data;
        GSource *source;
        GClosure *closure;

        data = g_slice_new (P0AlsaPlaystateChangedData);

        data->alsa = alsa;
        data->state = new_state;

        closure = g_cclosure_new(G_CALLBACK (p0_alsa_emit_playstate_changed),
                                 data,
                                 (GClosureNotify) p0_alsa_playstate_changed_data_free);
        g_object_watch_closure(G_OBJECT (alsa),
                               closure);

        source = g_idle_source_new();
        g_source_set_priority(source,
                              G_PRIORITY_HIGH);
        g_source_set_closure(source,
                             closure);
        g_source_attach(source,
                        NULL);
        g_source_unref(source);
}

typedef struct
{
        P0Alsa *alsa;
        gchar *errorstring;
} P0AlsaErrorData;

static void p0_alsa_error_free(P0AlsaErrorData *data)
{
        g_free(data->errorstring);
        g_slice_free (P0AlsaErrorData, data);
}

static gboolean p0_alsa_emit_errorstring(P0AlsaErrorData *data)
{
        g_signal_emit(data->alsa,
                      p0_alsa_signals[ERROR_OCCURED],
                      0,
                      data->errorstring);
        return FALSE;
}

static void p0_alsa_error_occured(P0Alsa *alsa, const gchar *string)
{
        P0AlsaErrorData *data = g_slice_new (P0AlsaErrorData);

        GSource *source;
        GClosure *closure;

        data->alsa = alsa;
        data->errorstring = g_strdup(string);

        closure = g_cclosure_new(G_CALLBACK (p0_alsa_emit_errorstring),
                                 data,
                                 (GClosureNotify) p0_alsa_error_free);
        g_object_watch_closure(G_OBJECT (alsa),
                               closure);

        source = g_idle_source_new();
        g_source_set_priority(source,
                              G_PRIORITY_HIGH);
        g_source_set_closure(source,
                             closure);
        g_source_attach(source,
                        NULL);
        g_source_unref(source);
}

void
p0_alsa_set_filter(P0Alsa *alsa,
                   gfloat lowdb,
                   gfloat middb,
                   gfloat highdb)
{

        g_return_if_fail (IS_P0_ALSA (alsa));

        alsa->eq_params.fFilter1Gain = lowdb;
        alsa->eq_params.fFilter2Gain = middb;
        alsa->eq_params.fFilter3Gain = highdb;

        p0_eq_setparams(alsa->eq, &alsa->eq_params);

        return;
}

void
p0_alsa_get_filter(P0Alsa *alsa,
                   gfloat *lowdb,
                   gfloat *middb,
                   gfloat *highdb)
{
        g_return_if_fail (IS_P0_ALSA (alsa));

        *lowdb =  alsa->eq_params.fFilter1Gain;
        *middb =  alsa->eq_params.fFilter2Gain;
        *highdb = alsa->eq_params.fFilter3Gain;

        return;
}
