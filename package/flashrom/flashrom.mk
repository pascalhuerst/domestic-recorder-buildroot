#############################################################
#
# flashrom
#
#############################################################
FLASHROM_VERSION:=0.9.1
FLASHROM_SOURCE:=flashrom-$(FLASHROM_VERSION).tar.bz2
FLASHROM_SITE:=http://qa.coreboot.com/releases/
FLASHROM_DIR:=$(BUILD_DIR)/flashrom-$(FLASHROM_VERSION)
FLASHROM_CAT:=$(BZ2CAT)
FLASHROM_BINARY:=flashrom
FLASHROM_TARGET_BINARY:=sbin/flashrom

$(DL_DIR)/$(FLASHROM_SOURCE):
	$(call DOWNLOAD,$(FLASHROM_SITE),$(FLASHROM_SOURCE))

flashrom-source: $(DL_DIR)/$(FLASHROM_SOURCE)

$(FLASHROM_DIR)/.unpacked: $(DL_DIR)/$(FLASHROM_SOURCE)
	$(FLASHROM_CAT) $(DL_DIR)/$(FLASHROM_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	$(CONFIG_UPDATE) $(FLASHROM_DIR)
	touch $@

$(FLASHROM_DIR)/.configured: $(FLASHROM_DIR)/.unpacked
	touch $@

$(FLASHROM_DIR)/$(FLASHROM_BINARY): $(FLASHROM_DIR)/.configured
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(FLASHROM_DIR)

$(TARGET_DIR)/$(FLASHROM_TARGET_BINARY): $(FLASHROM_DIR)/$(FLASHROM_BINARY)
	install -D $(FLASHROM_DIR)/$(FLASHROM_BINARY) $(TARGET_DIR)/$(FLASHROM_TARGET_BINARY)

flashrom: uclibc $(TARGET_DIR)/$(FLASHROM_TARGET_BINARY)

flashrom-clean:
	rm -f $(TARGET_DIR)/$(FLASHROM_TARGET_BINARY)
	-$(MAKE) -C $(FLASHROM_DIR) clean

flashrom-dirclean:
	rm -rf $(FLASHROM_DIR)
#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_FLASHROM),y)
TARGETS+=flashrom
endif
