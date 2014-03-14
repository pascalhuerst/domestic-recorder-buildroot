################################################################################
#
# taglib
#
################################################################################

TAGLIB_VERSION = 1.7.2
TAGLIB_SOURCE = taglib-$(TAGLIB_VERSION).tar.gz
TAGLIB_SITE = http://developer.kde.org/~wheeler/files/src
TAGLIB_INSTALL_STAGING = YES
TAGLIB_DEPENDENCIES = host-pkgconf libglib2

ifeq ($(BR2_PACKAGE_ZLIB),y)
TAGLIB_DEPENDENCIES += zlib
endif

ifeq ($(BR2_PACKAGE_TAGLIB_ASF),y)
TAGLIB_CONF_OPT += -DWITH_ASF=ON
endif

ifeq ($(BR2_PACKAGE_TAGLIB_MP4),y)
TAGLIB_CONF_OPT += -DWITH_MP4=ON
endif

define TAGLIB_REMOVE_DEVFILE
	rm -f $(TARGET_DIR)/usr/bin/taglib-config
endef

TAGLIB_POST_INSTALL_TARGET_HOOKS += TAGLIB_REMOVE_DEVFILE

$(eval $(cmake-package))
