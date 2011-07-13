#############################################################
#
# libiconv
#
#############################################################
LIBICONV_VERSION = 1.12
LIBICONV_SOURCE = libiconv-$(LIBICONV_VERSION).tar.gz
LIBICONV_SITE = $(BR2_GNU_MIRROR)/libiconv
LIBICONV_AUTORECONF = NO
LIBICONV_INSTALL_STAGING = YES
LIBICONV_INSTALL_TARGET = YES

# Remove not used preloadable libiconv.so
define LIBICONV_TARGET_REMOVE_PRELOADABLE_LIBS
	rm -f $(TARGET_DIR)/usr/lib/preloadable_libiconv.so
endef

define LIBICONV_STAGING_REMOVE_PRELOADABLE_LIBS
	rm -f $(STAGING_DIR)/usr/lib/preloadable_libiconv.so
endef

LIBICONV_POST_INSTALL_TARGET_HOOKS += LIBICONV_TARGET_REMOVE_PRELOADABLE_LIBS
LIBICONV_POST_INSTALL_STAGING_HOOKS += LIBICONV_STAGING_REMOVE_PRELOADABLE_LIBS

$(eval $(call AUTOTARGETS,package,libiconv))
