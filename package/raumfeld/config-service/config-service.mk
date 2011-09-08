#############################################################
#
# config-service
#
#############################################################
CONFIG_SERVICE_VERSION:=$(call qstrip,$(BR2_PACKAGE_RAUMFELD_BRANCH))
CONFIG_SERVICE_DIR:=$(BUILD_DIR)/config-service-$(CONFIG_SERVICE_VERSION)
CONFIG_SERVICE_TARGET_DIR:=raumfeld/config-service
CONFIG_SERVICE_BINARY:=$(CONFIG_SERVICE_TARGET_DIR)/config-service
CONFIG_SERVICE_CROSS_PREFIX:=$(BASE_DIR)

CONFIG_SERVICE_DEPENDENCIES = host-pkg-config libraumfeld libraumfeldcpp

ifeq ($(ARCH),arm)
CONFIG_SERVICE_CROSS = ARM
endif

ifeq ($(ARCH),i586)
CONFIG_SERVICE_CROSS = GEODE
endif

ifeq ($(ARCH),i386)
CONFIG_SERVICE_CROSS = GEODE
endif

$(CONFIG_SERVICE_DIR)/.bzr:
	test ! -z "$(CONFIG_SERVICE_CROSS)" || \
		(echo "config-service can only be built for ARM or GEODE"; exit -1)
	if ! test -d $(CONFIG_SERVICE_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
		mkdir -p config-service-$(CONFIG_SERVICE_VERSION); \
	 	$(call qstrip,$(BR2_BZR_CO)) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/config-service/$(CONFIG_SERVICE_VERSION) config-service-$(CONFIG_SERVICE_VERSION)) \
	fi
	touch -c $@

config-service-source: $(CONFIG_SERVICE_DIR)/.bzr 

$(STAGING_DIR)/$(CONFIG_SERVICE_BINARY): config-service-source
	$(MAKE) -C $(CONFIG_SERVICE_DIR) CROSS=$(CONFIG_SERVICE_CROSS) DEST=$(STAGING_DIR)/raumfeld CROSS_PREFIX=$(CONFIG_SERVICE_CROSS_PREFIX)

$(TARGET_DIR)/$(CONFIG_SERVICE_BINARY): $(STAGING_DIR)/$(CONFIG_SERVICE_BINARY)
	$(MAKE) -C $(CONFIG_SERVICE_DIR) CROSS=$(CONFIG_SERVICE_CROSS) DEST=$(TARGET_DIR)/raumfeld CROSS_PREFIX=$(CONFIG_SERVICE_CROSS_PREFIX)

config-service: $(CONFIG_SERVICE_DEPENDENCIES) $(TARGET_DIR)/$(CONFIG_SERVICE_BINARY)

config-service-clean:
	rm -rf $(STAGING_DIR)/$(CONFIG_SERVICE_TARGET_DIR)
	rm -rf $(TARGET_DIR)/$(CONFIG_SERVICE_TARGET_DIR)
	-$(MAKE) -C $(CONFIG_SERVICE_DIR) clean CROSS=$(CONFIG_SERVICE_CROSS)

config-service-dirclean:
	rm -rf $(CONFIG_SERVICE_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_RAUMFELD_CONFIG_SERVICE),y)
TARGETS+=config-service
endif
