#############################################################
#
# taglib
#
#############################################################
TAGLIB_VERSION = 1.5
TAGLIB_SOURCE = taglib-$(TAGLIB_VERSION).tar.gz
TAGLIB_SITE = http://developer.kde.org/~wheeler/files/src
TAGLIB_LIBTOOL_PATCH = NO
TAGLIB_INSTALL_STAGING = YES

TAGLIB_DEPENDENCIES = host-pkg-config libglib2

TAGLIB_CONF_ENV = \
	USER_INCLUDES="`PKG_CONFIG_SYSROOT_DIR=$(STAGING_DIR) $(HOST_DIR)/usr/bin/pkg-config --cflags gio-2.0`" \
	USER_LDFLAGS="-L$(STAGING_DIR)/usr/lib `PKG_CONFIG_SYSROOT_DIR=$(STAGING_DIR) $(HOST_DIR)/usr/bin/pkg-config --libs gio-2.0`" \
	DO_NOT_COMPILE='bindings tests examples' \
	ac_cv_header_cppunit_extensions_HelperMacros_h=no \
	ac_cv_header_zlib_h=$(if $(BR2_PACKAGE_ZLIB),yes,no)

TAGLIB_CONF_OPT = --disable-libsuffix --program-prefix=''

define TAGLIB_REMOVE_DEVFILE
	rm -f $(TARGET_DIR)/usr/bin/taglib-config
endef

define TAGLIB_STAGING_LINK_SO
	ln -sf libtag $(STAGING_DIR)/usr/lib/libtag.so
	ln -sf libtag.1 $(STAGING_DIR)/usr/lib/libtag.so.1
endef

define TAGLIB_TARGET_LINK_SO
	ln -sf libtag $(TARGET_DIR)/usr/lib/libtag.so
	ln -sf libtag.1 $(TARGET_DIR)/usr/lib/libtag.so.1
endef

TAGLIB_POST_INSTALL_STAGING_HOOKS += TAGLIB_STAGING_LINK_SO
TAGLIB_POST_INSTALL_TARGET_HOOKS += TAGLIB_TARGET_LINK_SO

ifneq ($(BR2_HAVE_DEVFILES),y)
TAGLIB_POST_INSTALL_TARGET_HOOKS += TAGLIB_REMOVE_DEVFILE
endif

$(eval $(call AUTOTARGETS,package/multimedia,taglib))
