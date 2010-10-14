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
CRDA_TARGET_BINARY:=$(TARGET_DIR)/usr/sbin/crda

$(CRDA_DIR)/.stamp_downloaded:
	$(Q)test -e $(DL_DIR)/$(CRDA_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(BR2_PRIMARY_SITE)/$(CRDA_SOURCE) || \
	$(WGET) -O $(DL_DIR)/$(CRDA_SOURCE) "$(CRDA_URL)"
	$(Q)mkdir -p $(CRDA_DIR)
	$(Q)touch $@

$(CRDA_DIR)/.unpacked: $(CRDA_DIR)/.stamp_downloaded
	$(CRDA_CAT) $(DL_DIR)/$(CRDA_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

CRDA_MAKE_ENV:=\
	PKG_CONFIG_SYSROOT_DIR=$(STAGING_DIR) \
	PKG_CONFIG_PATH=$(STAGING_DIR)/usr/lib/pkgconfig \
	CFLAGS="-I$(STAGING_DIR)/usr/include $(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	BUILDDIR=$(CRDA_DIR) \
	UDEV_RULE_DIR=/etc/udev/rules.d \
	CROSS=$(TARGET_CROSS) CC=$(TARGET_CC) \
	USE_OPENSSL=1 \
	PUBKEY_DIR=/usr/lib/crda/pubkeys

$(CRDA_TARGET_BINARY): $(CRDA_DIR)/.unpacked
	$(CRDA_MAKE_ENV) $(MAKE) -C $(CRDA_DIR) all_noverify
	$(CRDA_MAKE_ENV) $(MAKE) -C $(CRDA_DIR) DESTDIR=$(STAGING_DIR) install
	$(call MESSAGE,"Installing to target")
	$(INSTALL) -m 0755 $(STAGING_DIR)/sbin/crda $(TARGET_DIR)/sbin
	$(STRIPCMD) $(STRIP_STRIP_ALL) $(TARGET_DIR)/sbin/crda
	$(INSTALL) -d $(TARGET_DIR)/etc/udev/rules.d
	$(INSTALL) $(STAGING_DIR)/etc/udev/rules.d/85-regulatory.rules $(TARGET_DIR)/etc/udev/rules.d

crda: libnl openssl $(TARGET_DIR)/usr/sbin/crda

crda-source: $(CRDA_DIR)/.stamp_downloaded

crda-clean:
	rm -f $(addprefix $(TARGET_DIR),/sbin/crda \
					/etc/udev/rules.d/85-regulatory.rules)
	rm -f $(addprefix $(STAGING_DIR),/sbin/crda \
					/sbin/regdbdump \
					/etc/udev/rules.d/85-regulatory.rules \
					/usr/share/man/man8/crda.8.gz \
					/usr/share/man/man8/regdbdump.8.gz)
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
