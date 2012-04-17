#############################################################
#
# udev
#
#############################################################
UDEV_VERSION = 181
UDEV_SOURCE = udev-$(UDEV_VERSION).tar.bz2
UDEV_SITE = $(BR2_KERNEL_MIRROR)/linux/utils/kernel/hotplug/
UDEV_INSTALL_STAGING = YES

# mq_getattr is in librt
UDEV_CONF_ENV += LIBS=-lrt

UDEV_CONF_OPT =			\
	--sbindir=/sbin		\
	--with-rootlibdir=/lib	\
	--libexecdir=/lib	\
	--with-firmware-path=/lib/firmware		\
	--with-usb-ids-path=/usr/share/hwdata/usb.ids	\
	--with-pci-ids-path=/usr/share/hwdata/pci.ids

UDEV_DEPENDENCIES = host-gperf host-pkg-config util-linux kmod

ifeq ($(BR2_PACKAGE_UDEV_ACL),y)
UDEV_CONF_OPT += --enable-udev_acl
UDEV_DEPENDENCIES += acl
endif

ifeq ($(BR2_PACKAGE_UDEV_GUDEV),y)
UDEV_DEPENDENCIES += libglib2
else
UDEV_CONF_OPT += --disable-gudev
endif

ifeq ($(BR2_PACKAGE_UDEV_HWDATA),y)
UDEV_DEPENDENCIES += hwdata
endif

ifeq ($(BR2_PACKAGE_UDEV_INTROSPECTION),y)
UDEV_DEPENDENCIES += libglib2
else
UDEV_CONF_OPT += --disable-introspection
endif

ifneq ($(BR2_PACKAGE_UDEV_KEYMAP),y)
UDEV_CONF_OPT += --disable-keymap
endif

ifneq ($(BR2_PACKAGE_UDEV_MTD),y)
UDEV_CONF_OPT += --disable-mtd_probe
endif

ifeq ($(BR2_PACKAGE_UDEV_RULES_GEN),y)
UDEV_CONF_OPT += --enable-rule_generator
endif

define UDEV_INSTALL_INITSCRIPT
	$(INSTALL) -m 0755 package/udev/S10udev $(TARGET_DIR)/etc/init.d/S10udev
endef

UDEV_POST_INSTALL_TARGET_HOOKS += UDEV_INSTALL_INITSCRIPT

$(eval $(call AUTOTARGETS))
