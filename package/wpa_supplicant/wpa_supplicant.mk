#############################################################
#
# wpa_supplicant
#
#############################################################

WPA_SUPPLICANT_VERSION = 0.7.3
WPA_SUPPLICANT_SOURCE = wpa_supplicant-$(WPA_SUPPLICANT_VERSION).tar.gz
WPA_SUPPLICANT_SITE = http://hostap.epitest.fi/releases
WPA_SUPPLICANT_LIBTOOL_PATCH = NO
WPA_SUPPLICANT_INSTALL_TARGET_OPT = DESTDIR=$(TARGET_DIR) install
WPA_SUPPLICANT_DEPENDENCIES = uclibc
WPA_SUPPLICANT_CONFIG = $(WPA_SUPPLICANT_DIR)/wpa_supplicant/.config
WPA_SUPPLICANT_SUBDIR = wpa_supplicant
WPA_SUPPLICANT_TARGET_BINS = wpa_cli wpa_supplicant wpa_passphrase
WPA_SUPPLICANT_DBUS_SERVICE = fi.epitest.hostap.WPASupplicant


ifeq ($(BR2_PACKAGE_MADWIFI),y)
	WPA_SUPPLICANT_DEPENDENCIES += madwifi
endif

ifeq ($(BR2_PACKAGE_WPA_SUPPLICANT_OPENSSL),y)
	WPA_SUPPLICANT_DEPENDENCIES += openssl
endif
ifeq ($(BR2_PACKAGE_DBUS),y)
	WPA_SUPPLICANT_DEPENDENCIES += host-pkgconfig dbus
	WPA_SUPPLICANT_MAKE_ENV = \
		PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)"	\
		PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig"
endif

$(eval $(call AUTOTARGETS,package,wpa_supplicant))

$(WPA_SUPPLICANT_TARGET_CONFIGURE):
	cp $(WPA_SUPPLICANT_DIR)/wpa_supplicant/defconfig $(WPA_SUPPLICANT_CONFIG)
	echo "CFLAGS += $(TARGET_CFLAGS)" >>$(WPA_SUPPLICANT_CONFIG)
	echo "CC = $(TARGET_CC)" >>$(WPA_SUPPLICANT_CONFIG)
	$(SED) "s/\/local//" $(WPA_SUPPLICANT_DIR)/wpa_supplicant/Makefile
ifneq ($(BR2_PACKAGE_WPA_SUPPLICANT_EAP),y)
	$(SED) "s/^\(CONFIG_.*EAP.*\)/#\1/g" $(WPA_SUPPLICANT_CONFIG)
else
ifeq ($(BR2_PACKAGE_WPA_SUPPLICANT_OPENSSL),y)
	echo "CONFIG_TLS=openssl" >>$(WPA_SUPPLICANT_CONFIG)
else
	echo "CONFIG_TLS=internal" >>$(WPA_SUPPLICANT_CONFIG)
	echo "CONFIG_INTERNAL_LIBTOMMATH=y" >>$(WPA_SUPPLICANT_CONFIG)
endif
endif
ifeq ($(BR2_PACKAGE_DBUS),y)
	echo "CONFIG_CTRL_IFACE_DBUS=y" >>$(WPA_SUPPLICANT_CONFIG)
endif
ifeq ($(BR2_PACKAGE_MADWIFI),y)
	echo "CONFIG_DRIVER_MADWIFI=y" >>$(WPA_SUPPLICANT_CONFIG)
	echo "CFLAGS += -I/$(MADWIFI_DIR)" >>$(WPA_SUPPLICANT_CONFIG)
endif

	touch $@

$(WPA_SUPPLICANT_HOOK_POST_INSTALL):
ifneq ($(BR2_PACKAGE_WPA_SUPPLICANT_CLI),y)
	rm -f $(TARGET_DIR)/usr/sbin/wpa_cli
endif
ifneq ($(BR2_PACKAGE_WPA_SUPPLICANT_PASSPHRASE),y)
	rm -f $(TARGET_DIR)/usr/sbin/wpa_passphrase
endif
ifeq ($(BR2_PACKAGE_DBUS),y)
	$(INSTALL) -D \
	  $(WPA_SUPPLICANT_DIR)/wpa_supplicant/dbus/dbus-wpa_supplicant.conf \
	  $(TARGET_DIR)/etc/dbus-1/system.d/wpa_supplicant.conf
	$(INSTALL) -D \
	  $(WPA_SUPPLICANT_DIR)/wpa_supplicant/dbus/$(WPA_SUPPLICANT_DBUS_SERVICE).service \
	  $(TARGET_DIR)/usr/share/dbus-1/system-services/$(WPA_SUPPLICANT_DBUS_SERVICE).service
endif

$(WPA_SUPPLICANT_TARGET_UNINSTALL):
	$(call MESSAGE,"Uninstalling")
	rm -f $(addprefix $(TARGET_DIR)/usr/sbin/, $(WPA_SUPPLICANT_TARGET_BINS))
	rm -f $(TARGET_DIR)/etc/dbus-1/system.d/wpa_supplicant.conf
	rm -f $(TARGET_DIR)/usr/share/dbus-1/system-services/$(WPA_SUPPLICANT_DBUS_SERVICE).service
	rm -f $(WPA_SUPPLICANT_TARGET_INSTALL_TARGET) $(WPA_SUPPLICANT_HOOK_POST_INSTALL)

