################################################################################
#
# stm32flash
#
################################################################################

STM32FLASH_VERSION = 0.4
STM32FLASH_SOURCE = stm32flash-$(STM32FLASH_VERSION).tar.gz
STM32FLASH_SITE = https://releases.stm32flash.googlecode.com/git
STM32FLASH_LICENSE = GPLv2+

define STM32FLASH_BUILD_CMDS
	$(MAKE) -C $(@D) \
		CC="$(TARGET_CC)" COPT_FLAGS="$(TARGET_CFLAGS)"
endef

define STM32FLASH_INSTALL_TARGET_CMDS
	$(INSTALL) -m 755 -D $(@D)/stm32flash $(TARGET_DIR)/usr/sbin/stm32flash
endef

$(eval $(generic-package))
