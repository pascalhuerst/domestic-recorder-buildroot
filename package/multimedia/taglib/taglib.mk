#############################################################
#
# taglib
#
#############################################################
TAGLIB_VERSION = 1.7
TAGLIB_SOURCE = taglib-$(TAGLIB_VERSION).tar.gz
TAGLIB_SITE = http://developer.kde.org/~wheeler/files/src
TAGLIB_INSTALL_STAGING = YES

TAGLIB_DEPENDENCIES = host-pkg-config libglib2

define TAGLIB_INSTALL_TARGET_CMDS
	cp -a $(STAGING_DIR)/usr/lib/libtag.so* $(TARGET_DIR)/usr/lib
endef

define TAGLIB_UNINSTALL_TARGET_CMDS
        rm -f $(TARGET_DIR)/usr/lib/libtag.so*
endef

$(eval $(call CMAKETARGETS,package/multimedia,taglib))
