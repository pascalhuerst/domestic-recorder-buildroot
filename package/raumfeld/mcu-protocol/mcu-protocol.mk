############################################################
#
# mcu-protocol
#
#############################################################

MCU_PROTOCOL_VERSION = $(call qstrip,$(BR2_PACKAGE_MCU_PROTOCOL_VERSION))
MCU_PROTOCOL_SITE = $(call qstrip,$(BR2_PACKAGE_MCU_PROTOCOL_REPOSITORY))
MCU_PROTOCOL_SITE_METHOD = git

MCU_PROTOCOL_DEPENDENCIES = alsa-lib

define MCU_PROTOCOL_BUILD_CMDS
	PATH=$(BR_PATH) $(MAKE) CROSS_COMPILE="$(TARGET_CROSS)" -C $(@D) 
endef

define MCU_PROTOCOL_INSTALL_TARGET_CMDS
	PATH=$(BR_PATH) $(MAKE) CROSS_COMPILE="$(TARGET_CROSS)" \
		DESTDIR=$(TARGET_DIR) ALSAPLUGINDIR=/usr/lib/alsa-lib -C $(@D) install 
endef

$(eval $(generic-package))
