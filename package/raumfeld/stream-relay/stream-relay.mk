#############################################################
#
# stream-relay
#
#############################################################
STREAM_RELAY_VERSION:=$(call qstrip,$(BR2_PACKAGE_RAUMFELD_BRANCH))
STREAM_RELAY_DIR:=$(BUILD_DIR)/stream-relay-$(STREAM_RELAY_VERSION)
STREAM_RELAY_TARGET_DIR:=raumfeld/stream-relay
STREAM_RELAY_BINARY:=$(STREAM_RELAY_TARGET_DIR)/stream-relay
STREAM_RELAY_CROSS_PREFIX:=$(BASE_DIR)

STREAM_RELAY_DEPENDENCIES = host-pkg-config libraumfeld libraumfeldcpp libmms libvorbis taglib

ifeq ($(ARCH),arm)
STREAM_RELAY_CROSS = ARM
endif

ifeq ($(ARCH),i586)
STREAM_RELAY_CROSS = GEODE
endif

$(STREAM_RELAY_DIR)/.bzr:
	test ! -z "$(STREAM_RELAY_CROSS)" || \
		(echo "stream-relay can only be built for ARM or GEODE"; exit -1)
	if ! test -d $(STREAM_RELAY_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
		mkdir -p stream-relay-$(STREAM_RELAY_VERSION); \
	 	$(call qstrip,$(BR2_BZR_CO)) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/stream-relay/$(STREAM_RELAY_VERSION) stream-relay-$(STREAM_RELAY_VERSION); \
		cd stream-relay-trunk && patch -p0 < ../../../package/raumfeld/stream-relay/stream-relay-buildroot.patch) \
	fi
	touch -c $@

stream-relay-source: $(STREAM_RELAY_DIR)/.bzr 

$(STAGING_DIR)/$(STREAM_RELAY_BINARY): stream-relay-source
	$(MAKE) -C $(STREAM_RELAY_DIR) CROSS=$(STREAM_RELAY_CROSS) DEST=$(STAGING_DIR)/raumfeld CROSS_PREFIX=$(STREAM_RELAY_CROSS_PREFIX)

$(TARGET_DIR)/$(STREAM_RELAY_BINARY): $(STAGING_DIR)/$(STREAM_RELAY_BINARY)
	$(MAKE) -C $(STREAM_RELAY_DIR) CROSS=$(STREAM_RELAY_CROSS) DEST=$(TARGET_DIR)/raumfeld CROSS_PREFIX=$(STREAM_RELAY_CROSS_PREFIX)
	$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/$(STREAM_RELAY_BINARY)

stream-relay: $(STREAM_RELAY_DEPENDENCIES) $(TARGET_DIR)/$(STREAM_RELAY_BINARY)

stream-relay-clean:
	rm -rf $(STAGING_DIR)/$(STREAM_RELAY_TARGET_DIR)
	rm -rf $(TARGET_DIR)/$(STREAM_RELAY_TARGET_DIR)
	-$(MAKE) -C $(STREAM_RELAY_DIR) clean CROSS=$(STREAM_RELAY_CROSS)

stream-relay-dirclean:
	rm -rf $(STREAM_RELAY_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_RAUMFELD_STREAM_RELAY),y)
TARGETS+=stream-relay
endif
