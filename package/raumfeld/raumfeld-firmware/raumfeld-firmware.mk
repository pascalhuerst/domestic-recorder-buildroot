################################################################################
#
# raumfeld-firmware
#
################################################################################

RAUMFELD_FIRMWARE_SOURCE =
RAUMFELD_FIRMWARE_DIR_PREFIX = package/raumfeld/raumfeld-firmware

ifeq ($(BR2_PACKAGE_RAUMFELD_FIRMWARE_ADAU1701),y)
RAUMFELD_FIRMWARE_FILES += adau1701.bin
endif

ifeq ($(BR2_PACKAGE_RAUMFELD_FIRMWARE_PCIE8897),y)
RAUMFELD_FIRMWARE_FILES += mrvl/pcie8897_uapsta.bin
endif

ifneq ($(RAUMFELD_FIRMWARE_FILES),)
define RAUMFELD_FIRMWARE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/firmware
	$(TAR) c -C $(RAUMFELD_FIRMWARE_DIR_PREFIX) $(sort $(RAUMFELD_FIRMWARE_FILES)) | \
		$(TAR) x -C $(TARGET_DIR)/lib/firmware
endef
endif

$(eval $(generic-package))
