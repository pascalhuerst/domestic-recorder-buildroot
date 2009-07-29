#ifndef __P0_ALSA_H__
#define __P0_ALSA_H__

/* general defines */
#define FRAMESPERPERIODE            1024
#define SAMPLERATE                  44100
#define NUMPERIODS                  32
#define BYTESPERFRAME               4
#define BYTESPERSECOND              (SAMPLERATE * BYTESPERFRAME * 2)
#define MAXSTRETCHFRAMES            250
#define OUTOFLOCKDELTA              4096
#define JITTERDIST                  (SAMPLERATE*10)
#define STARTJITTERDIST             (JITTERDIST/2)
#define PUNCHDELTASEC               2
#define ALSAJITTERBUFLEN            4096
#define ALSASLEEPTIME               (22 * FRAMESPERPERIODE)
#define CAPTUREPERIODFRAMES	    4096



#define TYPE_P0_ALSA            (p0_alsa_get_type ())
#define P0_ALSA(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_P0_ALSA, P0Alsa))
#define P0_ALSA_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_P0_ALSA, P0AlsaClass))
#define IS_P0_ALSA(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_P0_ALSA))
#define IS_P0_ALSA_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_P0_ALSA))
#define P0_ALSA_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_P0_ALSA, P0AlsaClass))


typedef struct _P0AlsaClass P0AlsaClass;


struct _P0AlsaClass
{
        GObjectClass parent_class;

        /*  signals  */
        void (* ready)              (P0Alsa    *alsa);
        void (* play_state_changed) (P0Alsa    *alsa,
                                     PlayState  new_playstate);
        void (* buffer_filled)      (P0Alsa    *alsa);
        void (* error_occured)      (P0Alsa    *alsa);
};


GType       p0_alsa_get_type              (void) G_GNUC_CONST;

P0Alsa     *p0_alsa_new                   (TimeClient  *time_client,
                                           const gchar *device_name_playback,
                                           const gchar *device_name_capture,
                                           P0Feedback  *feedback);

void        p0_alsa_run                   (P0Alsa      *alsa);

void        p0_alsa_handover_data         (P0Alsa      *alsa,
                                           guint        buffer_length,
                                           gpointer     buffer);

void        p0_alsa_stop_stream           (P0Alsa      *alsa);

void        p0_alsa_notify_stream_incoming(P0Alsa      *alsa);

void        p0_alsa_notify_play_pressed   (P0Alsa      *alsa);

void        p0_alsa_notify_end_stream     (P0Alsa      *alsa);

void        p0_alsa_set_next_trigger_time (P0Alsa      *alsa,
                                           const gchar *trigger_time);

void        p0_alsa_get_punch_time        (P0Alsa         *alsa,
                                           struct timeval *punch_time);

void        p0_alsa_set_filter            (P0Alsa         *alsa,
                                           gfloat         lowdb,
                                           gfloat         middb,
                                           gfloat         highdb);

void        p0_alsa_get_filter            (P0Alsa         *alsa,
                                           gfloat         *lowdb,
                                           gfloat         *middb,
                                           gfloat         *highdb);

void        p0_alsa_get_punch_time        (P0Alsa         *alsa,
                                           struct timeval *punch_time);


#endif  /*  __P0_ALSA_H__  */

