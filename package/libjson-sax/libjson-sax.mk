################################################################################
#
# libjson-sax
#
################################################################################

LIBJSON_SAX_VERSION = bd0cad8b3f063bedd95d27b32211b9fc388cf24f
LIBJSON_SAX_SITE = $(call github,vincenthz,libjson,$(LIBJSON_SAX_VERSION))
LIBJSON_SAX_LICENSE = LGPLv2.1+

LIBJSON_SAX_SO_MAJOR = 1
LIBJSON_SAX_SO_MINOR = 0
LIBJSON_SAX_SO_MICRO = 0

LIBJSON_SAX_SO_VERSION = $(LIBJSON_SAX_SO_MAJOR).$(LIBJSON_SAX_SO_MINOR).$(LIBJSON_SAX_SO_MICRO)

define LIBJSON_SAX_BUILD_CMDS
	$(MAKE) -C $(@D) CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS) -fPIC"
endef

define LIBJSON_SAX_INSTALL_STAGING_CMDS
        $(MAKE) -C $(@D) PREFIX="$(STAGING_DIR)" install
endef

define LIBJSON_SAX_INSTALL_TARGET_CMDS
        $(INSTALL) -m 0755 -D $(@D)/libjson-sax.so.$(LIBJSON_SAX_SO_VERSION) $(TARGET_DIR)/usr/lib
	ln -sf libjson-sax.so.$(LIBJSON_SAX_SO_VERSION) $(TARGET_DIR)/usr/lib/libjson-sax.so.$(LIBJSON_SAX_SO_MAJOR).$(LIBJSON_SAX_SO_MINOR)
	ln -sf libjson-sax.so.$(LIBJSON_SAX_SO_VERSION) $(TARGET_DIR)/usr/lib/libjson-sax.so.$(LIBJSON_SAX_SO_MAJOR)
	ln -sf libjson-sax.so.$(LIBJSON_SAX_SO_VERSION) $(TARGET_DIR)/usr/lib/libjson-sax.so
endef

$(eval $(generic-package))
