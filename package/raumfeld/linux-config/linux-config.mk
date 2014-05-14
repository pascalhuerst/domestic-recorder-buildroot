#############################################################
#
# linux-config
#
#############################################################

define RAUMFELD_LINUX_CONFIG_ENABLE_SND_USB
	$(call KCONFIG_ENABLE_OPT,CONFIG_SND_USB,$(1))
endef

define RAUMFELD_LINUX_CONFIG_ENABLE_SND_USB_AUDIO
	$(call KCONFIG_SET_OPT,CONFIG_SND_USB_AUDIO,m,$(1))
endef

ifeq ($(BR2_RAUMFELD_LINUX_CONFIG_USB_AUDIO),y)
LINUX_CONFIGURE_HOOKS += RAUMFELD_LINUX_CONFIG_ENABLE_SND_USB
LINUX_CONFIGURE_HOOKS += RAUMFELD_LINUX_CONFIG_ENABLE_SND_USB_AUDIO
endif
