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

ifeq ($(BR2_UCLIBC_ARM_TYPE),"ARM_CORTEXA8")
STREAM_DECODER_CONF_OPT += --enable-32bit
endif

STREAM_DECODER_DEPENDENCIES = host-pkgconf host-libglib2 libsoup gstreamer1

$(eval $(raumfeld-autotools-package))
