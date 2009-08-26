#############################################################
#
# stream-relay
#
#############################################################
STREAM-RELAY_VERSION:=$(BR2_PACKAGE_RAUMFELD_BRANCH)
STREAM-RELAY_DIR:=$(BUILD_DIR)/stream-relay-$(STREAM-RELAY_VERSION)
STREAM-RELAY_TARGET_DIR:=raumfeld/stream-relay
STREAM-RELAY_BINARY:=$(STREAM-RELAY_TARGET_DIR)/stream-relay

ifeq ($(ARCH),arm)
STREAM-RELAY_CROSS=ARM
else
ifeq ($(ARCH),i586)
STREAM-RELAY_CROSS=GEODE
else
echo "renderer can only be build for ARM or GEODE"
exit 1
endif
endif

$(STREAM-RELAY_DIR)/.bzr:
	
	if ! test -d $(STREAM-RELAY_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
		mkdir -p stream-relay-$(RAUMFELD_VERSION); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/stream-relay/$(RAUMFELD_VERSION) stream-relay-$(RAUMFELD_VERSION)) \
	fi
	touch -c $@

stream-relay-source: $(STREAM-RELAY_DIR)/.bzr 

$(STAGING_DIR)/$(STREAM-RELAY_BINARY): stream-relay-source
	$(MAKE) -C $(STREAM-RELAY_DIR) CROSS=$(STREAM-RELAY_CROSS) DEST=$(STAGING_DIR)/raumfeld
	

$(TARGET_DIR)/$(STREAM-RELAY_BINARY): $(STAGING_DIR)/$(STREAM-RELAY_BINARY)
	$(MAKE) -C $(STREAM-RELAY_DIR) CROSS=$(STREAM-RELAY_CROSS) DEST=$(TARGET_DIR)/raumfeld
	$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/$(STREAM-RELAY_BINARY)

stream-relay: uclibc host-pkgconfig raumfeld raumfeldcpp flac libvorbis ffmpeg libmms $(TARGET_DIR)/$(STREAM-RELAY_BINARY)

stream-relay-clean:
	rm -f $(STAGING_DIR)/$(STREAM-RELAY_TARGET_DIR)
	rm -f $(STAGING_DIR)/$(TARGET_DIR)
	-$(MAKE) -C $(STREAM-RELAY_DIR) clean CROSS=$(STREAM-RELAY_CROSS)

stream-relay-dirclean:
	rm -rf $(STREAM-RELAY_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_RAUMFELD_STREAM-RELAY),y)
TARGETS+=stream-relay
endif
