#############################################################
#
# hostpapd
#
#############################################################
MADWIFI_VERSION = 0.9.4
MADWIFI_SOURCE = madwifi-$(MADWIFI_VERSION)-current.tar.gz
MADWIFI_SITE = http://snapshots.madwifi-project.org

MADWIFI_DIR:=$(BUILD_DIR)/madwifi-$(MADWIFI_VERSION)-r4100-20090929
MADWIFI_BINARY:=madwifi
MADWIFI_TARGET_BINARY:=wlanconfig

MADWIFI_DEPENDENCIES = uclibc linux26

$(DL_DIR)/$(MADWIFI_SOURCE):
	$(call DOWNLOAD,$(MADWIFI_SITE),$(MADWIFI_SOURCE))

$(MADWIFI_DIR)/.source: $(DL_DIR)/$(MADWIFI_SOURCE)
	$(ZCAT) $(DL_DIR)/$(MADWIFI_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(MADWIFI_DIR) package/madwifi/ madwifi-\*.patch
	touch $@

$(MADWIFI_DIR)/.configured: $(MADWIFI_DIR)/.source
	touch $@

$(MADWIFI_DIR)/tools/$(MADWIFI_BINARY): $(MADWIFI_DIR)/.configured
	$(MAKE) -C $(MADWIFI_DIR) KERNELPATH=$(PROJECT_BUILD_DIR)/linux- CROSS_COMPILE=$(TARGET_CROSS)


$(TARGET_DIR)/usr/bin/$(MADWIFI_TARGET_BINARY): $(MADWIFI_DIR)/tools/$(MADWIFI_BINARY)
	cp -dPf $(MADWIFI_DIR)/tools/$(MADWIFI_TARGET_BINARY) $(TARGET_DIR)/usr/bin/$(MADWIFI_TARGET_BINARY)
	$(MAKE) -C $(MADWIFI_DIR) KERNELPATH=$(PROJECT_BUILD_DIR)/linux- CROSS_COMPILE=$(TARGET_CROSS)  KMODPATH=$(TARGET_DIR)/lib/modules/$(BR2_DOWNLOAD_LINUX26_VERSION) install-modules
	/sbin/depmod -ae $(BR2_DOWNLOAD_LINUX26_VERSION) -b $(TARGET_DIR)
	touch $@

madwifi: $(MADWIFI_DEPENDENCIES) $(TARGET_DIR)/usr/bin/$(MADWIFI_TARGET_BINARY)

madwifi-source: $(DL_DIR)/$(MADWIFI_SOURCE)

madwifi-clean:
	$(MAKE) prefix=$(TARGET_DIR)/usr -C $(MADWIFI_DIR) uninstall
	-$(MAKE) -C $(MADWIFI_DIR) clean

madwifi-dirclean:
	rm -rf $(MADWIFI_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################

ifeq ($(BR2_PACKAGE_MADWIFI),y)
TARGETS+=madwifi
endif

















