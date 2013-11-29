################################################################################
#
# flac
#
################################################################################

FLAC_VERSION = 1.3.0
FLAC_SITE = http://downloads.xiph.org/releases/flac/
FLAC_SOURCE = flac-$(FLAC_VERSION).tar.xz
FLAC_INSTALL_STAGING = YES

FLAC_CONF_OPT = \
	--disable-cpplibs \
	--disable-xmms-plugin

ifeq ($(BR2_PACKAGE_LIBOGG),y)
FLAC_CONF_OPT += --with-ogg=$(STAGING_DIR)/usr
FLAC_DEPENDENCIES = libogg
else
FLAC_CONF_OPT += --disable-ogg
endif

$(eval $(autotools-package))
