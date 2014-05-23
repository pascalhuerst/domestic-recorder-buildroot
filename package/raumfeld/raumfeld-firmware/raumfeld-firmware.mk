################################################################################
#
# raumfeld-firmware
#
################################################################################

RAUMFELD_FIRMWARE_SOURCE =

ifeq ($(BR2_PACKAGE_RAUMFELD_FIRMWARE_ADAU1701),y)
RAUMFELD_FIRMWARE_FILES += adau1701.bin
endif

ifneq ($(RAUMFELD_FIRMWARE_FILES),)
define RAUMFELD_FIRMWARE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/firmware
	$(foreach file,$(RAUMFELD_FIRMWARE_FILES), \
		$(INSTALL) -m 0644 -D package/raumfeld/raumfeld-firmware/$(file) $(TARGET_DIR)/lib/firmware)
endef
endif

$(eval $(generic-package))
