#ifndef __P0_MIXER_H__
#define __P0_MIXER_H__


#define TYPE_P0_MIXER            (p0_mixer_get_type ())
#define P0_MIXER(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), TYPE_P0_MIXER, P0Mixer))
#define P0_MIXER_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), TYPE_P0_MIXER, P0MixerClass))
#define IS_P0_MIXER(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), TYPE_P0_MIXER))
#define IS_P0_MIXER_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), TYPE_P0_MIXER))
#define P0_MIXER_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj), TYPE_P0_MIXER, P0MixerClass))



typedef struct _P0MixerClass P0MixerClass;

struct _P0MixerClass
{
        GObjectClass parent_class;

        /*  signals  */
        void (* volume_changed) (P0Mixer *mixer);
        void (* mute_changed)   (P0Mixer *mixer);
};


GType       p0_mixer_get_type   (void) G_GNUC_CONST;

P0Mixer   * p0_mixer_new        (const gchar *device);

void        p0_mixer_set_volume (P0Mixer     *mixer,
                                 guint        volume);
guint       p0_mixer_get_volume (P0Mixer     *mixer);
void        p0_mixer_set_mute   (P0Mixer     *mixer,
                                 gboolean     mute);
gboolean    p0_mixer_get_mute   (P0Mixer     *mixer);


#endif  /*  __P0_MIXER_H__  */

