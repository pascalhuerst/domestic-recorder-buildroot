/*
 * p0-alsa-capture.c
 *
 *  Created on: Jun 1, 2009
 *      Author: mhirsch
 */

#include <string.h>
#include <sys/time.h>
#include <alsa/asoundlib.h>
#include <libgupnp/gupnp.h>
#include <raumfeld/time.h>

#include "p0-renderer-types.h"
#include "options.h"
#include "p0-alsa.h"
#include "p0-alsa-tools.h"
#include "p0-dsp.h"
#include "p0-streamserver.h"
#include "FLAC/metadata.h"
#include "FLAC/stream_encoder.h"

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

        P0StreamServer*         stream_server;

        gint                    max_l;
        gint                    max_r;

} P0AlsaCaptureData;

static P0AlsaCaptureData P0AlsaCapture;
static gpointer p0_alsa_audio_capture_loop(gpointer ptr);


FLAC__StreamEncoderWriteStatus flac_write_callback(const FLAC__StreamEncoder *encoder,
                                                   const FLAC__byte buffer[],
                                                   size_t bytes,
                                                   unsigned samples,
                                                   unsigned current_frame,
                                                   void *client_data);

FLAC__StreamEncoderSeekStatus seek_cb(const FLAC__StreamEncoder *encoder,
                                      FLAC__uint64 absolute_byte_offset,
                                      void *client_data);

FLAC__StreamEncoderTellStatus tell_cb(const FLAC__StreamEncoder *encoder,
                                      FLAC__uint64 *absolute_byte_offset,
                                      void *client_data);

gboolean p0_alsa_audio_capture_init(gchar *device_name_capture_param)
{
        snd_pcm_hw_params_alloca(&P0AlsaCapture.hwparams_capture);

        snd_pcm_sw_params_alloca(&P0AlsaCapture.swparams_capture);

        if (p0_alsa_tools_set_capture_params(device_name_capture_param,
                                             &P0AlsaCapture.capture_handle,
                                             P0AlsaCapture.hwparams_capture,
                                             P0AlsaCapture.swparams_capture,
                                             &P0AlsaCapture.frames_per_period_capture,
                                             &P0AlsaCapture.ringbufferframes_capture))
                return FALSE;

        P0AlsaCapture.terminate_loop = FALSE;

        P0AlsaCapture.buffer_alsa_capture = (char*) malloc(P0AlsaCapture.ringbufferframes_capture);

        memset(P0AlsaCapture.buffer_alsa_capture,
               0,
               P0AlsaCapture.ringbufferframes_capture);

        P0AlsaCapture.stream_server = p0_streamserver_new(55555,
                                                          8192,
                                                          "audio/x-flac");

        P0AlsaCapture.audio_capture_thread = g_thread_create (p0_alsa_audio_capture_loop,
                        &P0AlsaCapture,
                        TRUE,
                        NULL);

        if (!P0AlsaCapture.audio_capture_thread)
                g_error("!!->Alsa: wow, audio capture thread create not possible\n");

        return TRUE;
}

gboolean p0_alsa_audio_capture_exit()
{
        P0AlsaCapture.terminate_loop = TRUE;
        g_thread_join(P0AlsaCapture.audio_capture_thread);

        snd_pcm_close(P0AlsaCapture.capture_handle);

        free(P0AlsaCapture.buffer_alsa_capture);

        g_object_unref(P0AlsaCapture.stream_server);

        return TRUE;
}

static gpointer p0_alsa_audio_capture_loop(void *ptr)
{
        snd_pcm_sframes_t rc;
        int err;
        FLAC__bool ok = true;
        FLAC__StreamEncoder *encoder = 0;
        FLAC__StreamEncoderInitStatus init_status;
        FLAC__StreamMetadata *metadata[2];
        FLAC__StreamMetadata_VorbisComment_Entry entry;
        FLAC__int32 flac_buffer[CAPTUREPERIODFRAMES * 2];

        unsigned sample_rate = SAMPLERATE;
        unsigned channels = 2;
        unsigned bps = 16;

        //test_file = fopen("./test.flac","wb");

        if ((encoder = FLAC__stream_encoder_new()) == NULL)
        {
                g_error("Alsa->Flac Encode error\n");
        }

        //   	ok &= FLAC__stream_encoder_set_verify(encoder, true);
        ok &= FLAC__stream_encoder_set_compression_level(encoder,
                                                         2);
        ok &= FLAC__stream_encoder_set_channels(encoder,
                                                channels);
        ok &= FLAC__stream_encoder_set_bits_per_sample(encoder,
                                                       bps);
        ok &= FLAC__stream_encoder_set_sample_rate(encoder,
                                                   sample_rate);
        ok &= FLAC__stream_encoder_set_total_samples_estimate(encoder,
                                                              44100);
        ok &= FLAC__stream_encoder_set_streamable_subset(encoder,
                                                         1);
        //ok &= FLAC__stream_encoder_set_blocksize	  	( encoder, CAPTUREPERIODFRAMES);


        if ((metadata[0] = FLAC__metadata_object_new(FLAC__METADATA_TYPE_VORBIS_COMMENT)) == NULL
                        || (metadata[1] = FLAC__metadata_object_new(FLAC__METADATA_TYPE_PADDING)) == NULL
                        /* there are many tag (vorbiscomment) functions but these are convenient for this particular use: */
                        || !FLAC__metadata_object_vorbiscomment_entry_from_name_value_pair(&entry,
                                                                                        "ARTIST",
                                                                                        "RAUMFELD")
                        || !FLAC__metadata_object_vorbiscomment_append_comment (metadata[0],
                                                                               entry, /*copy=*/
                                                                               false)
                         /* copy=false: let metadata object take control of entry's allocated string */
                        ||  !FLAC__metadata_object_vorbiscomment_entry_from_name_value_pair(&entry,
                                                                                            "YEAR",
                                                                                            "2009")
                        || !FLAC__metadata_object_vorbiscomment_append_comment(metadata[0], entry, /*copy=*/false))
        {
                g_error("ERROR: out of memory or tag error\n");

                metadata[1]->length = 1234; /* set the padding length */

                ok = FLAC__stream_encoder_set_metadata(encoder,
                                                       metadata,
                                                       2);
        }

        init_status = FLAC__stream_encoder_init_stream(encoder,
                                                       flac_write_callback,
                                                       seek_cb,
                                                       tell_cb,
                                                       NULL,
                                                       ptr);

        if (init_status != FLAC__STREAM_ENCODER_INIT_STATUS_OK)
                g_error("Alsa->Flac Encode error\n");

        err = snd_pcm_start(P0AlsaCapture.capture_handle);

        if (err < 0)
                g_error("!!->Alsa: Start error: %s\n",
                                snd_strerror(err));

        while (!P0AlsaCapture.terminate_loop)
        {

                rc = snd_pcm_readi(P0AlsaCapture.capture_handle,
                                   P0AlsaCapture.buffer_alsa_capture,
                                   CAPTUREPERIODFRAMES);

                if (rc < 0)
                {
                        g_error("!!->Alsa: something wrong happend while captureing\n");
                }

                p0_dsp_get_minmax((short *) P0AlsaCapture.buffer_alsa_capture,
                                  CAPTUREPERIODFRAMES,
                                  &P0AlsaCapture.max_l,
                                  &P0AlsaCapture.max_r);

                int i;
                FLAC__byte *buffer = (FLAC__byte *) P0AlsaCapture.buffer_alsa_capture;

                for (i = 0; i < CAPTUREPERIODFRAMES * channels; i++)
                {
                        flac_buffer[i] = (FLAC__int32) (((FLAC__int16) (FLAC__int8) buffer[2* i + 1] << 8) | (FLAC__int16) buffer[2* i ]);
                }

                ok = FLAC__stream_encoder_process_interleaved(encoder,
                                                              flac_buffer,
                                                              CAPTUREPERIODFRAMES);

                if (ok == FALSE)
                {
                        g_error("Alsa->Flac Encode error %d\n", FLAC__stream_encoder_get_state(encoder));
                }

                P0AlsaCapture.byte_pos += CAPTUREPERIODFRAMES * BYTESPERFRAME;

        }

        ok &= FLAC__stream_encoder_finish(encoder);

        return NULL;
}

FLAC__StreamEncoderWriteStatus flac_write_callback(const FLAC__StreamEncoder *encoder,
                                                   const FLAC__byte buffer[],
                                                   size_t bytes,
                                                   unsigned samples,
                                                   unsigned current_frame,
                                                   void *client_data)
{

        p0_streamserver_eat(P0AlsaCapture.stream_server,
                            (gchar *) buffer,
                            bytes);

        return FLAC__STREAM_ENCODER_WRITE_STATUS_OK;
}

FLAC__StreamEncoderSeekStatus seek_cb(const FLAC__StreamEncoder *encoder,
                                      FLAC__uint64 absolute_byte_offset,
                                      void *client_data)
{
        return FLAC__STREAM_ENCODER_SEEK_STATUS_UNSUPPORTED;
}

FLAC__StreamEncoderTellStatus tell_cb(const FLAC__StreamEncoder *encoder,
                                      FLAC__uint64 *absolute_byte_offset,
                                      void *client_data)
{

        *absolute_byte_offset = P0AlsaCapture.byte_pos;
        return FLAC__STREAM_ENCODER_TELL_STATUS_OK;

}

void p0_alsa_audio_capture_get_minmax(gint *max_l,
                                      gint *max_r)
{
        *max_l = P0AlsaCapture.max_l;
        *max_r = P0AlsaCapture.max_r;
}
