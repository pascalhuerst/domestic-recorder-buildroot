/*
 * P0Mixer:
 *
 * This class controls the ALSA mixer devices for volume and mute.
 */

#include <alsa/asoundlib.h>

#include <glib-object.h>

#include "p0-renderer-types.h"
#include "p0-mixer.h"
#include "volume-table.h"


#define MIXER_VOLUME "Master Playback Volume"
#define MIXER_SWITCH "Master Playback Switch"


struct _P0Mixer
{
        GObject       parent_instance;

        snd_ctl_t    *handle;
        const gchar  *volume_name;   /* name of the volume control          */
        const gchar  *mute_name;     /* name of the mute control            */

        guint         volume;        /* volume mapped to the range [0..100] */
        gboolean      muted;

        glong         alsa_volume;   /* actual volume on the ALSA device    */

        glong         volume_min;
        glong         volume_max;
        const guint8 *volume_ramp;
};

enum
{
        VOLUME_CHANGED,
        MUTE_CHANGED,
        LAST_SIGNAL
};


static void       p0_mixer_finalize             (GObject     *object);

static void       p0_mixer_set_alsa_volume      (P0Mixer     *mixer,
                                                 guint        volume);
static gboolean   p0_mixer_get_alsa_volume      (P0Mixer     *mixer);
static void       p0_mixer_set_alsa_mute        (P0Mixer     *mixer,
                                                 gboolean     mute);
static gboolean   p0_mixer_get_alsa_mute        (P0Mixer     *mixer);

static glong      p0_mixer_volume_map           (P0Mixer     *mixer,
                                                 const guint  value);
static guint      p0_mixer_volume_unmap         (P0Mixer     *mixer,
                                                 const glong  value);

static void       p0_mixer_setup                (P0Mixer     *mixer,
                                                 gboolean     raumfeld);

static gboolean   p0_mixer_is_raumfeld_hardware (snd_ctl_t   *handle);


G_DEFINE_TYPE (P0Mixer, p0_mixer, G_TYPE_OBJECT)

static guint p0_mixer_signals[LAST_SIGNAL] = { 0 };


static void
p0_mixer_class_init (P0MixerClass* klass)
{
        GObjectClass *object_class = G_OBJECT_CLASS (klass);

        object_class->finalize = p0_mixer_finalize;

        p0_mixer_signals[VOLUME_CHANGED] =
                g_signal_new ("volume-changed",
                              G_TYPE_FROM_CLASS (klass),
                              G_SIGNAL_RUN_FIRST,
                              G_STRUCT_OFFSET (P0MixerClass, volume_changed),
                              NULL, NULL,
                              g_cclosure_marshal_VOID__VOID,
                              G_TYPE_NONE, 0);
        p0_mixer_signals[MUTE_CHANGED] =
                g_signal_new ("mute-changed",
                              G_TYPE_FROM_CLASS (klass),
                              G_SIGNAL_RUN_FIRST,
                              G_STRUCT_OFFSET (P0MixerClass, mute_changed),
                              NULL, NULL,
                              g_cclosure_marshal_VOID__VOID,
                              G_TYPE_NONE, 0);
}

static void
p0_mixer_finalize (GObject *object)
{
       P0Mixer *mixer = P0_MIXER (object);

       if (mixer->handle) {
               snd_ctl_close (mixer->handle);
               mixer->handle = NULL;
       }

       G_OBJECT_CLASS (p0_mixer_parent_class)->finalize (object);
}

P0Mixer *
p0_mixer_new (const gchar *device)
{
        P0Mixer   *mixer;
        snd_ctl_t *handle;
        gboolean   raumfeld;
        int        err;

        if (! device)
                device = "default";

        g_print ("->Mixer: opening mixer device named %s\n", device);

        err = snd_ctl_open (&handle, device, 0);

        if (err < 0) {
                g_printerr ("->Mixer: unable to open mixer device: %s\n",
                            snd_strerror (err));
                return NULL;
        }

        mixer = g_object_new (TYPE_P0_MIXER, NULL);

        mixer->handle      = handle;
        mixer->volume_name = MIXER_VOLUME;
        mixer->mute_name   = MIXER_SWITCH;

        raumfeld = p0_mixer_is_raumfeld_hardware (mixer->handle);

        p0_mixer_setup (mixer, raumfeld);

        if (! p0_mixer_get_alsa_volume (mixer)) {
                g_printerr ("->Mixer: Could not get initial volume!!");
        }
        if (! p0_mixer_get_alsa_mute (mixer)) {
                g_printerr ("->Mixer: Could not get initial mute state!!");
        }

        return mixer;
}


static void
p0_mixer_init (P0Mixer *mixer)
{
}

void
p0_mixer_set_volume (P0Mixer *mixer,
                     guint    volume)
{
        g_return_if_fail (IS_P0_MIXER (mixer));

        volume = CLAMP (volume, 0, 100);

        if (mixer->volume != volume) {
                mixer->volume = volume;

                p0_mixer_set_alsa_volume (mixer, mixer->volume);

                g_signal_emit (mixer, p0_mixer_signals[VOLUME_CHANGED], 0);
        }
}

guint
p0_mixer_get_volume (P0Mixer *mixer)
{
        g_return_val_if_fail (IS_P0_MIXER (mixer), 0);

        return mixer->volume;
}

void
p0_mixer_set_mute (P0Mixer  *mixer,
                   gboolean  mute)
{
        g_return_if_fail (IS_P0_MIXER (mixer));

        mute = (mute != FALSE);

        if (mixer->muted != mute) {
                mixer->muted = mute;

                p0_mixer_set_alsa_mute (mixer, mute);

                g_signal_emit (mixer, p0_mixer_signals[MUTE_CHANGED], 0);
        }
}

gboolean
p0_mixer_get_mute (P0Mixer *mixer)
{
        g_return_val_if_fail (IS_P0_MIXER (mixer), FALSE);

        return mixer->muted;
}

#define MIXER_CONTROL_INIT(handle, control_name)                        \
        snd_ctl_elem_info_t  *info;                                     \
        snd_ctl_elem_id_t    *id;                                       \
        snd_ctl_elem_value_t *control;                                  \
                                                                        \
        snd_ctl_elem_info_alloca (&info);                               \
        snd_ctl_elem_id_alloca (&id);                                   \
        snd_ctl_elem_value_alloca (&control);                           \
                                                                        \
        snd_ctl_elem_id_set_interface (id, SND_CTL_ELEM_IFACE_MIXER);   \
	snd_ctl_elem_id_set_name (id, control_name);                    \
        snd_ctl_elem_info_set_id (info, id);                            \
                                                                        \
        if (snd_ctl_elem_info (handle, info) < 0) {                     \
                g_printerr ("->Mixer: Cannot find mixer control '%s'\n",\
                            control_name);                              \
        } else {                                                        \
                snd_ctl_elem_info_get_id (info, id);                    \
                snd_ctl_elem_value_set_id (control, id);                \
        }                                                               \

static void
p0_mixer_set_alsa_volume (P0Mixer *mixer,
                          guint    volume)
{
        glong alsa_volume;
        guint count;
        guint idx;
        int   err;

        alsa_volume = p0_mixer_volume_map (mixer, volume);

        MIXER_CONTROL_INIT (mixer->handle, mixer->volume_name)

        count = snd_ctl_elem_info_get_count (info);

        for (idx = 0; idx < count && idx < 128; idx++)
                snd_ctl_elem_value_set_integer (control, idx, alsa_volume);

        err = snd_ctl_elem_write (mixer->handle, control);

        if (err < 0)
                g_printerr ("->Mixer:"
                            "Can't write to volume control: %s\n",
                            snd_strerror (err));
}

static gboolean
p0_mixer_get_alsa_volume (P0Mixer *mixer)
{
        glong alsa_volume;
        int   err;

        MIXER_CONTROL_INIT (mixer->handle, mixer->volume_name)

        err = snd_ctl_elem_read (mixer->handle, control);
        if (err < 0) {
                g_printerr ("->Mixer: Can't read from control element: %s\n",
                            snd_strerror (err));
                return FALSE;
        }

        alsa_volume = snd_ctl_elem_value_get_integer (control, 0);
        alsa_volume = CLAMP (alsa_volume, mixer->volume_min, mixer->volume_max);

        mixer->volume = p0_mixer_volume_unmap (mixer, alsa_volume);

        return TRUE;
}

static void
p0_mixer_set_alsa_switch (P0Mixer     *mixer,
                          const gchar *name,
                          gboolean     value)
{
        guint count;
        guint idx;
        int   err;

        MIXER_CONTROL_INIT (mixer->handle, name);

        count = snd_ctl_elem_info_get_count (info);

        for (idx = 0; idx < count && idx < 128; idx++)
                snd_ctl_elem_value_set_boolean (control, idx, value ? 1 : 0);

        err = snd_ctl_elem_write (mixer->handle, control);

        if (err < 0)
                g_printerr ("->Mixer: Can't control %s: %s\n",
                            name, snd_strerror (err));
}

static void
p0_mixer_set_alsa_mute (P0Mixer  *mixer,
                        gboolean  mute)
{
        p0_mixer_set_alsa_switch (mixer, mixer->mute_name, ! mute);
}

static gboolean
p0_mixer_get_alsa_mute (P0Mixer *mixer)
{
        guint count;
        guint idx;
        int   err;
        int   enabled = 0;

        MIXER_CONTROL_INIT (mixer->handle, mixer->mute_name)

        err = snd_ctl_elem_read (mixer->handle, control);
        if (err < 0) {
                g_printerr ("->Mixer: Can't read from control element: %s\n",
                            snd_strerror (err));
                return FALSE;
        }

        count = snd_ctl_elem_info_get_count (info);

        for (idx = 0; idx < count && idx < 128; idx++)
                enabled |= snd_ctl_elem_value_get_boolean (control, idx);

        mixer->muted = (enabled == 0);

        return TRUE;
}

static guint
p0_mixer_volume_unmap (P0Mixer     *mixer,
                       const glong  value)
{
        if (value <= mixer->volume_min)
                return 0;

        if (value >= mixer->volume_max)
                return 100;

        if (mixer->volume_ramp) {
                guint lower = 0;
                guint upper = 100;

                /*  binary search in volume_ramp  */
                while (lower < upper) {
                        const guint half = lower + (upper - lower) / 2;

                        if (value > mixer->volume_ramp[half]) {
                                lower = half + 1;
                        } else {
                                upper = half;
                        }
                }

                return lower;
        } else {
                const glong range = mixer->volume_max - mixer->volume_min;

                return ((100 *
                         (value - mixer->volume_min) + (range >> 1)) / range);
        }
}

static glong
p0_mixer_volume_map (P0Mixer     *mixer,
                     const guint  value)
{
        if (mixer->volume_ramp) {
                return mixer->volume_ramp[value];
        } else {
                const glong range = mixer->volume_max - mixer->volume_min;

                return mixer->volume_min + (value * range + 50) / 100;
        }
}

static void
p0_mixer_setup (P0Mixer  *mixer,
                gboolean  raumfeld)
{
        if (raumfeld) {
                mixer->volume_min  = 0;
                mixer->volume_max  = 255;
                mixer->volume_ramp = raumfeld_volume_ramp;

                p0_mixer_set_alsa_switch (mixer, "Soft Ramp Switch", TRUE);
                p0_mixer_set_alsa_switch (mixer, "Zero Cross Switch", TRUE);
        } else {
                MIXER_CONTROL_INIT (mixer->handle, mixer->volume_name)

                mixer->volume_min  = snd_ctl_elem_info_get_min (info);
                mixer->volume_max  = snd_ctl_elem_info_get_max (info);
                mixer->volume_ramp = NULL;
        }
}

static gboolean
p0_mixer_is_raumfeld_hardware (snd_ctl_t *handle)
{
        snd_ctl_card_info_t *info;
        int                  err;

        snd_ctl_card_info_alloca (&info);
        err = snd_ctl_card_info (handle, info);

        if (err < 0) {
                 g_printerr ("Error getting info about mixer device: %s\n",
                             snd_strerror (err));
        } else {
                 const gchar *name = snd_ctl_card_info_get_name (info);

                 if (name && strcmp (name, "Raumfeld analog") == 0) {
                         return TRUE;
                 }
        }

        return FALSE;
}
