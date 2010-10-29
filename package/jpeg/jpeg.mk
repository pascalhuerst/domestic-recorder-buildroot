#############################################################
#
# jpeg (libraries needed by some apps)
#
#############################################################
JPEG_VERSION = 8b
JPEG_SITE = http://www.ijg.org/files/
JPEG_SOURCE = jpegsrc.v$(JPEG_VERSION).tar.gz
JPEG_INSTALL_STAGING = YES
JPEG_INSTALL_TARGET = YES
JPEG_INSTALL_TARGET_OPT = DESTDIR=$(TARGET_DIR) install
JPEG_LIBTOOL_PATCH = NO

$(eval $(call AUTOTARGETS,package,jpeg))

$(JPEG_HOOK_POST_INSTALL):
	rm -f $(addprefix $(TARGET_DIR)/usr/bin/$(BR2_ARCH)-linux-,cjpeg djpeg jpegtrans rdjpgcom wrjpgcom)
	touch $@
