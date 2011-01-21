#############################################################
#
# web-service
#
#############################################################
WEB_SERVICE_VERSION:=$(call qstrip,$(BR2_PACKAGE_RAUMFELD_BRANCH))
WEB_SERVICE_DIR:=$(BUILD_DIR)/web-service-$(WEB_SERVICE_VERSION)
WEB_SERVICE_TARGET_DIR:=raumfeld/web-service
WEB_SERVICE_BINARY:=$(WEB_SERVICE_TARGET_DIR)/web-service
WEB_SERVICE_CROSS_PREFIX:=$(BUILD_DIR)/..

WEB_SERVICE_DEPENDENCIES = host-pkgconfig libraumfeld libraumfeldcpp

ifeq ($(ARCH),arm)
WEB_SERVICE_CROSS = ARM
endif

ifeq ($(ARCH),i586)
WEB_SERVICE_CROSS = GEODE
endif

$(WEB_SERVICE_DIR)/.bzr:
	test ! -z "$(WEB_SERVICE_CROSS)" || \
		(echo "web-service can only be built for ARM or GEODE"; exit -1)
	if ! test -d $(WEB_SERVICE_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
		mkdir -p web-service-$(WEB_SERVICE_VERSION); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/web-service/$(WEB_SERVICE_VERSION) web-service-$(WEB_SERVICE_VERSION)) \
	fi
	touch -c $@

web-service-source: $(WEB_SERVICE_DIR)/.bzr 

$(STAGING_DIR)/$(WEB_SERVICE_BINARY): web-service-source
	$(MAKE) -C $(WEB_SERVICE_DIR) CROSS=$(WEB_SERVICE_CROSS) DEST=$(STAGING_DIR)/raumfeld CROSS_PREFIX=$(WEB_SERVICE_CROSS_PREFIX)

$(TARGET_DIR)/$(WEB_SERVICE_BINARY): $(STAGING_DIR)/$(WEB_SERVICE_BINARY)
	$(MAKE) -C $(WEB_SERVICE_DIR) CROSS=$(WEB_SERVICE_CROSS) DEST=$(TARGET_DIR)/raumfeld CROSS_PREFIX=$(WEB_SERVICE_CROSS_PREFIX)
	$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/$(WEB_SERVICE_BINARY)

web-service: $(WEB_SERVICE_DEPENDENCIES) $(TARGET_DIR)/$(WEB_SERVICE_BINARY)

web-service-clean:
	rm -rf $(STAGING_DIR)/$(WEB_SERVICE_TARGET_DIR)
	rm -rf $(TARGET_DIR)/$(WEB_SERVICE_TARGET_DIR)
	-$(MAKE) -C $(WEB_SERVICE_DIR) clean CROSS=$(WEB_SERVICE_CROSS)

web-service-dirclean:
	rm -rf $(WEB_SERVICE_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_RAUMFELD_WEB_SERVICE),y)
TARGETS+=web-service
endif
