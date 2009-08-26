#############################################################
#
# p0-timeserver
#
#############################################################
P0_TIMESERVER_VERSION:=$(BR2_PACKAGE_RAUMFELD_BRANCH)
P0_TIMESERVER_DIR:=$(BUILD_DIR)/p0-timeserver-$(P0_TIMESERVER_VERSION)
P0_TIMESERVER_TARGET_DIR:=raumfeld/p0-timeserver
P0_TIMESERVER_BINARY:=$(P0_TIMESERVER_TARGET_DIR)/p0-timeserver

P0_TIMESERVER_DEPENDENCIES = host-pkgconfig libraumfeld

ifeq ($(ARCH),arm)
P0_TIMESERVER_CROSS=ARM
else
ifeq ($(ARCH),i586)
MASTER_PROCESS_CROSS=GEODE
else
echo "timeserver can only be build for ARM or GEODE"
exit 1
endif
endif

$(P0_TIMESERVER_DIR)/.bzr:
	if ! test -d $(P0_TIMESERVER_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
		mkdir -p p0-timeserver-$(P0_TIMESERVER_VERSION); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/p0-timeserver p0-timeserver-$(P0_TIMESERVER_VERSION)) \
	fi
	touch -c $@

p0-timeserver-source: $(P0_TIMESERVER_DIR)/.bzr

$(STAGING_DIR)/$(P0_TIMESERVER_BINARY): p0-timeserver-source
	$(MAKE) -C $(P0_TIMESERVER_DIR) CROSS=$(P0_TIMESERVER_CROSS) DEST=$(STAGING_DIR)/raumfeld


$(TARGET_DIR)/$(P0_TIMESERVER_BINARY): $(STAGING_DIR)/$(P0_TIMESERVER_BINARY)
	$(MAKE) -C $(P0_TIMESERVER_DIR) CROSS=$(P0_TIMESERVER_CROSS) DEST=$(TARGET_DIR)/raumfeld
	$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/$(P0_TIMESERVER_BINARY)

p0-timeserver: uclibc host-pkgconfig raumfeld $(TARGET_DIR)/$(P0_TIMESERVER_BINARY)

p0-timeserver-clean:
	rm -f $(STAGING_DIR)/$(P0_TIMESERVER_TARGET_DIR)
	rm -f $(STAGING_DIR)/$(TARGET_DIR)
	-$(MAKE) -C $(P0_TIMESERVER_DIR) clean CROSS=$(P0_TIMESERVER_CROSS)

p0-timeserver-dirclean:
	rm -rf $(P0_TIMESERVER_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_RAUMFELD_TIMESERVER),y)
TARGETS+=p0-timeserver
endif
