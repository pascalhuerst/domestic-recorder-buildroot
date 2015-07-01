#############################################################
#
# stream-decoder
#
#############################################################

STREAM_DECODER_INSTALL_STAGING = YES

STREAM_DECODER_CONF_OPTS = --disable-glibtest

ifeq ($(BR2_cortex_a8),y)
STREAM_DECODER_CONF_OPTS += --enable-32bit
endif

STREAM_DECODER_DEPENDENCIES = host-pkgconf host-libglib2 libsoup gstreamer1

$(eval $(raumfeld-autotools-package))
