#############################################################
#
# stream-decoder
#
#############################################################

STREAM_DECODER_INSTALL_STAGING = YES

ifeq ($(ARCH),arm)
STREAM_DECODER_CONF_ENV = ARM_TYPE="$(call qstrip,$(BR2_UCLIBC_ARM_TYPE))"
endif

STREAM_DECODER_CONF_OPT = --disable-glibtest

STREAM_DECODER_DEPENDENCIES = host-pkgconf libsoup gstreamer

$(eval $(raumfeld-autotools-package))
