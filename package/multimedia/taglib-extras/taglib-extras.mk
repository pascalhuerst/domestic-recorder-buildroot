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

define TAGLIB_EXTRAS_INSTALL_TARGET_CMDS
	cp -a $(STAGING_DIR)/usr/lib/libtag-extras.so* $(TARGET_DIR)/usr/lib
	$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/lib/libtag-extras.so.$(TAGLIB_EXTRAS_SOVERSION)
endef

define TAGLIB_EXTRAS_UNINSTALL_TARGET_CMDS
        rm -f $(TARGET_DIR)/usr/lib/libtag-extras.so*
endef

$(eval $(call CMAKETARGETS,package/multimedia,taglib-extras))
