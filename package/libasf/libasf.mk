################################################################################
#
# libasf
#
################################################################################

LIBASF_VERSION = b4f8b4d817
LIBASF_SITE = $(call github,raumfeld,libasf,master,$(LIBASF_VERSION))
LIBASF_INSTALL_STAGING = YES
LIBASF_LICENSE = LGPLv2.1+

define LIBASF_CONFIGURE_CMDS
        (cd $(@D); $(TARGET_CONFIGURE_OPTS) ./waf configure --prefix=/usr --libdir=/usr/lib)
endef

define LIBASF_BUILD_CMDS
        (cd $(@D); ./waf build)
endef

define LIBASF_INSTALL_STAGING_CMDS
        (cd $(@D); ./waf install --destdir=$(STAGING_DIR))
endef

define LIBASF_INSTALL_TARGET_CMDS
        $(INSTALL) -m 0755 -D $(@D)/build/src/libasf.so $(TARGET_DIR)/usr/lib
endef

$(eval $(generic-package))
