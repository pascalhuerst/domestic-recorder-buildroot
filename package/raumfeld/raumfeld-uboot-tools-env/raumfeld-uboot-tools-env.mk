################################################################################
#
# raumfeld-uboot-tools-env
#
################################################################################

RAUMFELD_UBOOT_TOOLS_ENV_SOURCE =
RAUMFELD_UBOOT_TOOLS_ENV_FW_CONFIG = fw_env.config
RAUMFELD_UBOOT_TOOLS_ENV_ARCH = $(shell echo $(BR2_CONFIG) | tr "\/" "\n" | tail -n 2 | head -n 1 | cut -d'-' -f3)

ifeq ($(RAUMFELD_UBOOT_TOOLS_ENV_ARCH),imx7)
	RAUMFELD_UBOOT_TOOLS_ENV_SRC_FW_CONFIG = imx7_fw_env.config
else ifeq ($(RAUMFELD_UBOOT_TOOLS_ENV_ARCH),armada)
	RAUMFELD_UBOOT_TOOLS_ENV_SRC_FW_CONFIG = armada_fw_env.config
else ifeq ($(RAUMFELD_UBOOT_TOOLS_ENV_ARCH),arm)
	RAUMFELD_UBOOT_TOOLS_ENV_SRC_FW_CONFIG = arm_fw_env.config
endif

ifneq ($(RAUMFELD_UBOOT_TOOLS_ENV_SRC_FW_CONFIG),)
define RAUMFELD_UBOOT_TOOLS_ENV_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0644 -D package/raumfeld/raumfeld-uboot-tools-env/$(RAUMFELD_UBOOT_TOOLS_ENV_SRC_FW_CONFIG) \
		$(TARGET_DIR)/etc/$(RAUMFELD_UBOOT_TOOLS_ENV_FW_CONFIG)
endef
endif

$(eval $(generic-package))
