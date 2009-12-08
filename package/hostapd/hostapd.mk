#############################################################
#
# hostpapd
#
#############################################################
HOSTAPD_VERSION = 0.6.9
HOSTAPD_SOURCE = hostapd-$(HOSTAPD_VERSION).tar.gz
HOSTAPD_SITE = http://hostap.epitest.fi/releases

HOSTAPD_DIR:=$(BUILD_DIR)/hostapd-$(HOSTAPD_VERSION)
HOSTAPD_BINARY:=hostapd
HOSTAPD_TARGET_BINARY:=usr/bin/hostapd

HOSTAPD_DEPENDENCIES = libnl openssl madwifi

$(DL_DIR)/$(HOSTAPD_SOURCE):
	$(call DOWNLOAD,$(HOSTAPD_SITE),$(HOSTAPD_SOURCE))

$(HOSTAPD_DIR)/.source: $(DL_DIR)/$(HOSTAPD_SOURCE)
	$(ZCAT) $(DL_DIR)/$(HOSTAPD_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

# hostpad has no configure script, we just copy a inlude file for make
$(HOSTAPD_DIR)/.configured: $(HOSTAPD_DIR)/.source
	cp -dPf package/hostapd/hostapd.config $(HOSTAPD_DIR)/hostapd/.config
	echo "CONFIG_DRIVER_MADWIFI=y" >>$(HOSTAPD_DIR)/hostapd/.config
	echo "CFLAGS += -I/$(MADWIFI_DIR)" >>$(HOSTAPD_DIR)/hostapd/.config
	touch $@

$(HOSTAPD_DIR)/hostapd/$(HOSTAPD_BINARY): $(HOSTAPD_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) -C $(HOSTAPD_DIR)/hostapd


$(TARGET_DIR)/$(HOSTAPD_TARGET_BINARY): $(HOSTAPD_DIR)/hostapd/$(HOSTAPD_BINARY)
	cp -dPf $(HOSTAPD_DIR)/hostapd/$(HOSTAPD_BINARY) $(TARGET_DIR)/$(HOSTAPD_TARGET_BINARY)
	touch $@

hostapd: $(HOSTAPD_DEPENDENCIES) $(TARGET_DIR)/$(HOSTAPD_TARGET_BINARY)
hostapd-source: $(DL_DIR)/$(HOSTAPD_SOURCE)

hostapd-clean:
	$(MAKE) prefix=$(TARGET_DIR)/usr -C $(HOSTAPD_DIR) uninstall
	-$(MAKE) -C $(HOSTAPD_DIR) clean

hostapd-dirclean:
	rm -rf $(HOSTAPD_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################

ifeq ($(BR2_PACKAGE_HOSTAPD),y)
TARGETS+=hostapd
endif

















