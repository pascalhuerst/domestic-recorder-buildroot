#############################################################
#
# meta-server
#
#############################################################
META-SERVER_VERSION:=$(BR2_PACKAGE_RAUMFELD_BRANCH)
META-SERVER_DIR:=$(BUILD_DIR)/meta-server-$(META-SERVER_VERSION)
META-SERVER_TARGET_DIR:=raumfeld/meta-server
META-SERVER_BINARY:=$(META-SERVER_TARGET_DIR)/meta-server

ifeq ($(ARCH),arm)
META-SERVER_CROSS=ARM
else
ifeq ($(ARCH),i586)
else
echo "renderer can only be build for ARM or GEODE"
exit 1
endif
endif

$(META-SERVER_DIR)/.bzr:
	
	if ! test -d $(META-SERVER_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
		mkdir -p meta-server-$(RAUMFELD_VERSION); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/meta-server/$(META-SERVER_VERSION) meta-server-$(RAUMFELD_VERSION)) \
	fi
	touch -c $@

meta-server-source: $(META-SERVER_DIR)/.bzr 

$(STAGING_DIR)/$(META-SERVER_BINARY): meta-server-source
	$(MAKE) -C $(META-SERVER_DIR) CROSS=$(META-SERVER_CROSS) DEST=$(STAGING_DIR)/raumfeld
	

$(TARGET_DIR)/$(META-SERVER_BINARY): $(STAGING_DIR)/$(META-SERVER_BINARY)
	$(MAKE) -C $(META-SERVER_DIR) CROSS=$(META-SERVER_CROSS) DEST=$(TARGET_DIR)/raumfeld
	$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/$(META-SERVER_BINARY)

meta-server: uclibc host-pkgconfig raumfeld sqlite taglib taglib-extras $(TARGET_DIR)/$(META-SERVER_BINARY)

meta-server-clean:
	rm -f $(STAGING_DIR)/$(META-SERVER_TARGET_DIR)
	rm -f $(STAGING_DIR)/$(TARGET_DIR)
	-$(MAKE) -C $(META-SERVER_DIR) clean CROSS=$(META-SERVER_CROSS)

meta-server-dirclean:
	rm -rf $(META-SERVER_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_RAUMFELD_META_SERVER),y)
TARGETS+=meta-server
endif
