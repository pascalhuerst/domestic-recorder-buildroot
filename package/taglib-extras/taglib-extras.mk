#############################################################
#
# taglib-extras
#
#############################################################
TAGLIB_EXTRAS_VERSION = 0.1.6
TAGLIB_EXTRAS_SOURCE = taglib-extras-$(TAGLIB_EXTRAS_VERSION).tar.gz
TAGLIB_EXTRAS_SITE = http://kollide.net/~jefferai
TAGLIB_EXTRAS_INSTALL_STAGING = YES

TAGLIB_EXTRAS_SOVERSION = 0.1.0

TAGLIB_EXTRAS_DEPENDENCIES = taglib

TAGLIB_EXTRAS_CONF_OPT = \
	-DCMAKE_LINKER_FLAGS=-L$(STAGING_DIR)/usr/lib \
	-DCMAKE_SHARED_LINKER_FLAGS=-L$(STAGING_DIR)/usr/lib \

define TAGLIB_EXTRAS_INSTALL_TARGET_CMDS
	cp -a $(STAGING_DIR)/usr/lib/libtag-extras.so* $(TARGET_DIR)/usr/lib
endef

$(eval $(cmake-package))
