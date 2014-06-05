#############################################################
#
# sfdisk
#
#############################################################

SFDISK_SOURCE = sfdisk.tar.bz2

define SFDISK_BUILD_CMDS
	$(MAKE) \
		CROSS=$(TARGET_CROSS) DEBUG=false OPTIMIZATION="$(TARGET_CFLAGS)" \
		DOLFS=$(if $(BR2_LARGEFILE),true,false) -C $(@D) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)"
endef

define SFDISK_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/sfdisk $(TARGET_DIR)/sbin/sfdisk
endef

$(eval $(generic-package))
