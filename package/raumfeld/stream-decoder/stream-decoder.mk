#############################################################
#
# stream-decoder
#
#############################################################

STREAM_DECODER_INSTALL_STAGING = YES

ifeq ($(ARCH),arm)
STREAM_DECODER_CONF_ENV = ARM_TYPE="$(call qstrip,$(BR2_ARM_TYPE))"
endif

STREAM_DECODER_CONF_OPT = --disable-glibtest

STREAM_DECODER_DEPENDENCIES = host-pkg-config libsoup gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-ffmpeg

$(eval $(raumfeld-autotools-package))
