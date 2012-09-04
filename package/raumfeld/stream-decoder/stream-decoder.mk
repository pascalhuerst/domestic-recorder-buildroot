#############################################################
#
# stream-decoder
#
#############################################################

STREAM_DECODER_INSTALL_STAGING = YES

STREAM_DECODER_CONF_OPT = --disable-glibtest

STREAM_DECODER_DEPENDENCIES = host-pkg-config libsoup gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-ffmpeg

$(eval $(raumfeld-autotools-package))
