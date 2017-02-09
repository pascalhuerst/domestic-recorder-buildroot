################################################################################
#
# raumfeld-uboot-tools-env
#
################################################################################

RAUMFELD_UBOOT_TOOLS_ENV_SOURCE =
RAUMFELD_UBOOT_TOOLS_ENV_ARCH = $(shell echo $(BR2_CONFIG) | tr "\/" "\n" | tail -n 2 | head -n 1 | cut -d'-' -f3)

define RAUMFELD_UBOOT_TOOLS_ENV_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0644 -D package/raumfeld/raumfeld-uboot-tools-env/$(RAUMFELD_UBOOT_TOOLS_ENV_ARCH)/* $(TARGET_DIR)/etc/
endef

$(eval $(generic-package))
