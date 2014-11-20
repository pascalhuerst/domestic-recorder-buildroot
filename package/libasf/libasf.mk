################################################################################
#
# libasf
#
################################################################################

LIBASF_VERSION = 93152f139d3bcb3cf18dda3bdc513172002de5b4
LIBASF_SITE = $(call github,juhovh,libasf,master,$(LIBASF_VERSION))
LIBASF_INSTALL_STAGING = YES
LIBASF_LICENSE = LGPLv2.1+

define LIBASF_CONFIGURE_CMDS
        (cd $(@D); \
                $(TARGET_CONFIGURE_OPTS)        \
                $(MAKE1) clean \
        )
endef

define LIBASF_BUILD_CMDS
        (cd $(@D); $(TARGET_CONFIGURE_OPTS) $(MAKE) -j $(PARALLEL_JOBS))
endef

define LIBASF_INSTALL_STAGING_CMDS
        (cd $(@D); $(TARGET_CONFIGURE_OPTS) $(MAKE) DESTDIR=$(STAGING_DIR) \
                install)
endef

define LIBASF_INSTALL_TARGET_CMDS
        (cd $(@D); $(TARGET_CONFIGURE_OPTS) $(MAKE) DESTDIR=$(TARGET_DIR) \
                install-exec)
endef

$(eval $(generic-package))

