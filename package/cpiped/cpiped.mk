################################################################################
#
# cpiped
#
################################################################################

CPIPED_VERSION = 3abe3cc6e09d65bf45a28cb8f9f8695acce1deb9
CPIPED_SITE = git@github.com:pascalhuerst/cpiped.git
CPIPED_SITE_METHOD = git
CPIPED_LICENSE = GPLv3+
CPIPED_LICENSE_FILES = LICENSE
CPIPED_DEPENDENCIES =
CPIPED_INSTALL_TARGET = YES
CPIPED_TARGET_DIR = $(TARGET_DIR)/usr/sbin
CPIPED_SOURCE_DIR = $(CPIPED_DIR)

define CPIPED_BUILD_CMDS
    CC="$(TARGET_CC)" $(MAKE) -C $(@D)
endef

define CPIPED_INSTALL_STAGING_CMDS
    $(INSTALL) -D -m 0755 $(@D)/cpiped $(STAGING_DIR)/usr/sbin
endef

define CPIPED_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/cpiped ${CPIPED_TARGET_DIR}
endef

$(eval $(generic-package))

