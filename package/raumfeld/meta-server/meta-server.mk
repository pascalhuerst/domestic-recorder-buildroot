#############################################################
#
# meta-server
#
#############################################################
META_SERVER_VERSION:=$(BR2_PACKAGE_RAUMFELD_BRANCH)
META_SERVER_DIR:=$(BUILD_DIR)/meta-server-$(META_SERVER_VERSION)
META_SERVER_TARGET_DIR:=raumfeld/meta-server
META_SERVER_BINARY:=$(META_SERVER_TARGET_DIR)/meta-server

META_SERVER_DEPENDENCIES = host-pkgconfig libraumfeld libraumfeldcpp sqlite taglib taglib-extras

ifeq ($(ARCH),arm)
META_SERVER_CROSS=ARM
else
ifeq ($(ARCH),i586)
else
echo "renderer can only be build for ARM or GEODE"
exit 1
endif
endif

$(META_SERVER_DIR)/.bzr:
	if ! test -d $(META_SERVER_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
		mkdir -p meta-server-$(META_SERVER_VERSION); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/meta-server/$(META_SERVER_VERSION) meta-server-$(META_SERVER_VERSION)) \
	fi
	touch -c $@

meta-server-source: $(META_SERVER_DIR)/.bzr 

$(STAGING_DIR)/$(META_SERVER_BINARY): meta-server-source
	$(MAKE) -C $(META_SERVER_DIR) CROSS=$(META_SERVER_CROSS) DEST=$(STAGING_DIR)/raumfeld

$(TARGET_DIR)/$(META_SERVER_BINARY): $(STAGING_DIR)/$(META_SERVER_BINARY)
	$(MAKE) -C $(META_SERVER_DIR) CROSS=$(META_SERVER_CROSS) DEST=$(TARGET_DIR)/raumfeld
	$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/$(META_SERVER_BINARY)

meta-server: $(META_SERVER_DEPENDENCIES) $(TARGET_DIR)/$(META_SERVER_BINARY)

meta-server-clean:
	rm -f $(STAGING_DIR)/$(META_SERVER_TARGET_DIR)
	rm -f $(STAGING_DIR)/$(TARGET_DIR)
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
