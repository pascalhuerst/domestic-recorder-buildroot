#############################################################
#
# libnl
#
#############################################################

LIBNL_VERSION = 2.0
LIBNL_SOURCE = libnl-$(LIBNL_VERSION).tar.gz
LIBNL_SITE = http://people.suug.ch/~tgr/libnl/files
LIBNL_INSTALL_STAGING = YES
LIBNL_INSTALL_TARGET_OPT = DESTDIR=$(TARGET_DIR) install
LIBNL_AUTORECONF = YES

$(eval $(call AUTOTARGETS,package,libnl))

$(LIBNL_HOOK_POST_INSTALL): $(LIBNL_TARGET_INSTALL_TARGET)
	$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/lib/libnl.so*
	touch $@

$(LIBNL_TARGET_UNINSTALL):
	$(call MESSAGE,"Uninstalling")
	rm -f $(TARGET_DIR)/usr/lib/libnl.so*
	rm -f $(LIBNL_TARGET_INSTALL_TARGET) $(LIBNL_HOOK_POST_INSTALL)
