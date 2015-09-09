############################################################
#
# mcu-protocol
#
#############################################################

MCU_PROTOCOL_VERSION = $(call qstrip,$(BR2_PACKAGE_MCU_PROTOCOL_VERSION))
MCU_PROTOCOL_SITE = $(call qstrip,$(BR2_PACKAGE_MCU_PROTOCOL_REPOSITORY))
MCU_PROTOCOL_SITE_METHOD = git

ifeq ($(BR2_PACKAGE_MCU_PROTOCOL_DAEMON),y)
MCU_PROTOCOL_DEPENDENCIES = alsa-lib
endif


ifeq ($(BR2_PACKAGE_MCU_PROTOCOL_DAEMON),y)
define MCU_PROTOCOL_BUILD_RFPD
	PATH=$(BR_PATH) $(MAKE) CROSS_COMPILE="$(TARGET_CROSS)" -C $(@D)
endef
define MCU_PROTOCOL_INSTALL_RFPD
	PATH=$(BR_PATH) $(MAKE) CROSS_COMPILE="$(TARGET_CROSS)" \
		DESTDIR=$(TARGET_DIR) ALSAPLUGINDIR=/usr/lib/alsa-lib -C $(@D) install
	$(INSTALL) -D -m 755 $(@D)/S97rfpd $(TARGET_DIR)/etc/init.d
endef
endif

ifeq ($(BR2_PACKAGE_MCU_PROTOCOL_TOOLS),y)
define MCU_PROTOCOL_BUILD_TOOLS
	PATH=$(BR_PATH) $(MAKE) tools CROSS_COMPILE="$(TARGET_CROSS)" -C $(@D)
endef
define MCU_PROTOCOL_INSTALL_TOOLS
	PATH=$(BR_PATH) $(MAKE) CROSS_COMPILE="$(TARGET_CROSS)" DESTDIR=$(TARGET_DIR) -C $(@D) install-tools
endef
endif


define MCU_PROTOCOL_BUILD_CMDS
$(MCU_PROTOCOL_BUILD_RFPD)
$(MCU_PROTOCOL_BUILD_TOOLS)
endef

define MCU_PROTOCOL_INSTALL_TARGET_CMDS
$(MCU_PROTOCOL_INSTALL_RFPD)
$(MCU_PROTOCOL_INSTALL_TOOLS)
endef

$(eval $(generic-package))

mcu-protocol-dlclean:
	rm -f $(DL_DIR)/$(MCU_PROTOCOL_SOURCE)
