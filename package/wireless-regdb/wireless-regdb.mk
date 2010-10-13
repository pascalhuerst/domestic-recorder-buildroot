#############################################################
#
# wireless-regdb
#
#############################################################
WIRELESS_REGDB_VERSION:=f3ba942
WIRELESS_REGDB_SOURCE:=wireless-regdb-$(WIRELESS_REGDB_VERSION).tar.gz
WIRELESS_REGDB_URL:=http://git.kernel.org/?p=linux/kernel/git/linville/wireless-regdb.git;a=snapshot;h=$(WIRELESS_REGDB_VERSION);sf=tgz
WIRELESS_REGDB_CAT:=$(ZCAT)
WIRELESS_REGDB_NAME:=wireless-regdb-$(WIRELESS_REGDB_VERSION)
WIRELESS_REGDB_DIR:=$(BUILD_DIR)/$(WIRELESS_REGDB_NAME)

$(WIRELESS_REGDB_DIR)/.stamp_downloaded:
	$(Q)test -e $(DL_DIR)/$(WIRELESS_REGDB_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(BR2_PRIMARY_SITE)/$(WIRELESS_REGDB_SOURCE) || \
	$(WGET) -O $(DL_DIR)/$(WIRELESS_REGDB_SOURCE) "$(WIRELESS_REGDB_URL)"
	$(Q)mkdir -p $(WIRELESS_REGDB_DIR)
	$(Q)touch $@

$(WIRELESS_REGDB_DIR)/.unpacked: $(WIRELESS_REGDB_DIR)/.stamp_downloaded
	$(WIRELESS_REGDB_CAT) $(DL_DIR)/$(WIRELESS_REGDB_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

$(TARGET_DIR)/usr/lib/crda/regulatory.bin: $(WIRELESS_REGDB_DIR)/.unpacked
	$(MAKE) -C $(WIRELESS_REGDB_DIR) DESTDIR=$(STAGING_DIR) install
	$(call MESSAGE,"Installing to target")
	$(INSTALL) -d $(TARGET_DIR)/usr/lib/crda/pubkeys
	$(INSTALL) $(STAGING_DIR)/usr/lib/crda/regulatory.bin $(TARGET_DIR)/usr/lib/crda
	$(INSTALL) $(STAGING_DIR)/usr/lib/crda/pubkeys/*.pem $(TARGET_DIR)/usr/lib/crda/pubkeys

wireless-regdb: $(TARGET_DIR)/usr/lib/crda/regulatory.bin

wireless-regdb-source: $(WIRELESS_REGDB_DIR)/.stamp_downloaded

wireless-regdb-clean:
	rm -rf $(addprefix $(TARGET_DIR),/usr/lib/crda/pubkeys)
	rm -f  $(addprefix $(TARGET_DIR),/usr/lib/crda/regulatory.bin)
	-$(MAKE) -C $(WIRELESS_REGDB_DIR) DESTDIR=$(STAGING_DIR) uninstall
	-$(MAKE) -C $(WIRELESS_REGDB_DIR) clean

wireless-regdb-dirclean:
	rm -rf $(WIRELESS_REGDB_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_WIRELESS_REGDB),y)
TARGETS+=wireless-regdb
endif
