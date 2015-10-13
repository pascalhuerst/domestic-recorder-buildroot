#############################################################
#
# stream-decoder
#
#############################################################

STREAM_DECODER_INSTALL_STAGING = YES

ifeq ($(BR2_cortex_a8),y)
STREAM_DECODER_CONF_OPTS += -DENABLE_32_BIT
endif

STREAM_DECODER_DEPENDENCIES = libsoup gstreamer1

$(eval $(raumfeld-cmake-package))
