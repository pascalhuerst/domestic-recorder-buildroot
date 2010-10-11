#############################################################
#
# meta-server
#
#############################################################
META_SERVER_VERSION:=$(call qstrip,$(BR2_PACKAGE_RAUMFELD_BRANCH))
META_SERVER_DIR:=$(BUILD_DIR)/meta-server-$(META_SERVER_VERSION)
META_SERVER_TARGET_DIR:=raumfeld/meta-server
META_SERVER_BINARY:=$(META_SERVER_TARGET_DIR)/meta-server
META_SERVER_CROSS_PREFIX:=$(BUILD_DIR)/..


META_SERVER_DEPENDENCIES = host-pkgconfig libraumfeld libraumfeldcpp iso-codes sqlite taglib taglib-extras

ifeq ($(ARCH),arm)
META_SERVER_CROSS = ARM
endif

ifeq ($(ARCH),i586)
META_SERVER_CROSS = GEODE
endif

$(META_SERVER_DIR)/.bzr:
	test ! -z "$(META_SERVER_CROSS)" || \
		(echo "meta-server can only be built for ARM or GEODE"; exit -1)
	if ! test -d $(META_SERVER_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
		mkdir -p meta-server-$(META_SERVER_VERSION); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/meta-server/$(META_SERVER_VERSION) meta-server-$(META_SERVER_VERSION)) \
	fi
	touch -c $@

meta-server-source: $(META_SERVER_DIR)/.bzr 

$(STAGING_DIR)/$(META_SERVER_BINARY): meta-server-source
	$(MAKE) -C $(META_SERVER_DIR) CROSS=$(META_SERVER_CROSS) DEST=$(STAGING_DIR)/raumfeld CROSS_PREFIX=$(STREAM_RELAY_CROSS_PREFIX)

$(TARGET_DIR)/$(META_SERVER_BINARY): $(STAGING_DIR)/$(META_SERVER_BINARY)
	$(MAKE) -C $(META_SERVER_DIR) CROSS=$(META_SERVER_CROSS) DEST=$(TARGET_DIR)/raumfeld CROSS_PREFIX=$(STREAM_RELAY_CROSS_PREFIX)
	$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/$(META_SERVER_BINARY)

meta-server: $(META_SERVER_DEPENDENCIES) $(TARGET_DIR)/$(META_SERVER_BINARY)

meta-server-clean:
	rm -rf $(STAGING_DIR)/$(META_SERVER_TARGET_DIR)
	rm -rf $(TARGET_DIR)/$(META_SERVER_TARGET_DIR)
	-$(MAKE) -C $(META_SERVER_DIR) clean CROSS=$(META_SERVER_CROSS)

meta-server-dirclean:
	rm -rf $(META_SERVER_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_RAUMFELD_META_SERVER),y)
TARGETS+=meta-server
endif
