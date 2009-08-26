#############################################################
#
# stream-relay
#
#############################################################
STREAM_RELAY_VERSION:=$(BR2_PACKAGE_RAUMFELD_BRANCH)
STREAM_RELAY_DIR:=$(BUILD_DIR)/stream-relay-$(STREAM_RELAY_VERSION)
STREAM_RELAY_TARGET_DIR:=raumfeld/stream-relay
STREAM_RELAY_BINARY:=$(STREAM_RELAY_TARGET_DIR)/stream-relay

STREAM_RELAY_DEPENDENCIES = host-pkgconfig libraumfeld libraumfeldcpp flac ffmpeg libmms libvorbis

ifeq ($(ARCH),arm)
STREAM_RELAY_CROSS=ARM
else
ifeq ($(ARCH),i586)
STREAM_RELAY_CROSS=GEODE
else
echo "renderer can only be build for ARM or GEODE"
exit 1
endif
endif

$(STREAM_RELAY_DIR)/.bzr:
	if ! test -d $(STREAM_RELAY_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
		mkdir -p stream-relay-$(STREAM_RELAY_VERSION); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/stream-relay/$(STREAM_RELAY_VERSION) stream-relay-$(STREAM_RELAY_VERSION)) \
	fi
	touch -c $@

stream-relay-source: $(STREAM_RELAY_DIR)/.bzr 

$(STAGING_DIR)/$(STREAM_RELAY_BINARY): stream-relay-source
	$(MAKE) -C $(STREAM_RELAY_DIR) CROSS=$(STREAM_RELAY_CROSS) DEST=$(STAGING_DIR)/raumfeld
	

$(TARGET_DIR)/$(STREAM_RELAY_BINARY): $(STAGING_DIR)/$(STREAM_RELAY_BINARY)
	$(MAKE) -C $(STREAM_RELAY_DIR) CROSS=$(STREAM_RELAY_CROSS) DEST=$(TARGET_DIR)/raumfeld
	$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/$(STREAM_RELAY_BINARY)

stream-relay: uclibc host-pkgconfig raumfeld raumfeldcpp flac libvorbis ffmpeg libmms $(TARGET_DIR)/$(STREAM_RELAY_BINARY)

stream-relay-clean:
	rm -f $(STAGING_DIR)/$(STREAM_RELAY_TARGET_DIR)
	rm -f $(STAGING_DIR)/$(TARGET_DIR)
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
