################################################################################
#
# libasf
#
################################################################################

LIBASF_VERSION = 93152f139d3bcb3cf18dda3bdc513172002de5b4
LIBASF_SITE = $(call github,juhovh,libasf,master,$(LIBASF_VERSION))
LIBASF_LICENSE = LGPLv2.1+ 
LIBASF_DEPENDENCIES = host-python

define LIBASF_CONFIGURE_CMDS
        (cd $(@D); \
                $(TARGET_CONFIGURE_OPTS)        \
                $(HOST_DIR)/usr/bin/python2 ./waf configure --prefix=/usr )
endef

define LIBASF_BUILD_CMDS
        (cd $(@D); $(HOST_DIR)/usr/bin/python2 ./waf build -j $(PARALLEL_JOBS))
endef

define LIBASF_INSTALL_TARGET_CMDS
        (cd $(@D); $(HOST_DIR)/usr/bin/python2 ./waf --destdir=$(TARGET_DIR) \
                install)
endef

$(eval $(generic-package))

