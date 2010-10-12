#############################################################
#
# crda
#
#############################################################
CRDA_VERSION:=52300e7
CRDA_SOURCE:=crda-$(CRDA_VERSION).tar.gz
CRDA_URL:=http://git.kernel.org/?p=linux/kernel/git/mcgrof/crda.git;a=snapshot;h=$(CRDA_VERSION);sf=tgz
CRDA_CAT:=$(ZCAT)
CRDA_NAME:=crda-$(CRDA_VERSION)
CRDA_DIR:=$(BUILD_DIR)/$(CRDA_NAME)

$(CRDA_DIR)/.stamp_downloaded:
	$(Q)test -e $(DL_DIR)/$(CRDA_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(BR2_PRIMARY_SITE)/$(CRDA_SOURCE) || \
	$(WGET) -O $(DL_DIR)/$(CRDA_SOURCE) "$(CRDA_URL)"
	$(Q)mkdir -p $(CRDA_DIR)
	$(Q)touch $@

$(CRDA_DIR)/.unpacked: $(CRDA_DIR)/.stamp_downloaded
	$(CRDA_CAT) $(DL_DIR)/$(CRDA_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

CRDA_MAKE_OPTS:=\
	PKG_CONFIG_SYSROOT_DIR=$(STAGING_DIR) \
	PKG_CONFIG_PATH=$(STAGING_DIR)/usr/lib/pkgconfig \
	CFLAGS="-I$(STAGING_DIR)/usr/include $(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	BUILDDIR=$(CRDA_DIR) \
	UDEV_RULE_DIR=/etc/udev/rules.d \
	CROSS=$(TARGET_CROSS) CC=$(TARGET_CC) \

$(CRDA_DIR)/crda: $(CRDA_DIR)/.unpacked
	$(CRDA_MAKE_OPTS) $(MAKE) -C $(CRDA_DIR) USE_OPENSSL=1 all_noverify

$(TARGET_DIR)/usr/sbin/crda: $(CRDA_DIR)/crda
	$(CRDA_MAKE_OPTS) $(MAKE) -C $(CRDA_DIR) DESTDIR=$(TARGET_DIR) install

crda: libnl openssl $(TARGET_DIR)/usr/sbin/crda

crda-source: $(CRDA_DIR)/.stamp_downloaded

crda-clean:
	rm -f $(TARGET_DIR)/usr/sbin/crda
	rm -f $(TARGET_DIR)/usr/sbin/regdbdump
	rm -f $(TARGET_DIR)/etc/udev/rules.d/85-regulatory.rules
	-$(MAKE) -C $(CRDA_DIR) clean

crda-dirclean:
	rm -rf $(CRDA_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_CRDA),y)
TARGETS+=crda
endif
