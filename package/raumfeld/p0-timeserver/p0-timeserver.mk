#############################################################
#
# p0-timeserver
#
#############################################################
P0_TIMESERVER_VERSION:=$(call qstrip,$(BR2_PACKAGE_RAUMFELD_BRANCH))
P0_TIMESERVER_DIR:=$(BUILD_DIR)/p0-timeserver-$(P0_TIMESERVER_VERSION)
P0_TIMESERVER_TARGET_DIR:=raumfeld/p0-timeserver
P0_TIMESERVER_BINARY:=$(P0_TIMESERVER_TARGET_DIR)/p0-timeserver
P0_TIMESERVER_CROSS_PREFIX:=$(BUILD_DIR)/..


P0_TIMESERVER_DEPENDENCIES = host-pkg-config libraumfeld

ifeq ($(ARCH),arm)
P0_TIMESERVER_CROSS = ARM
endif

ifeq ($(ARCH),i586)
P0_TIMESERVER_CROSS = GEODE
endif

$(P0_TIMESERVER_DIR)/.bzr:
	test ! -z "$(P0_TIMESERVER_CROSS)" || \
		(echo "timeserver can only be built for ARM or GEODE"; exit -1)
	if ! test -d $(P0_TIMESERVER_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
		mkdir -p p0-timeserver-$(P0_TIMESERVER_VERSION); \
	 	$(call qstrip,$(BR2_BZR_CO)) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/p0-timeserver/$(P0_TIMESERVER_VERSION) p0-timeserver-$(P0_TIMESERVER_VERSION)) \
	fi
	touch -c $@

p0-timeserver-source: $(P0_TIMESERVER_DIR)/.bzr

$(STAGING_DIR)/$(P0_TIMESERVER_BINARY): p0-timeserver-source
	$(MAKE) -C $(P0_TIMESERVER_DIR) CROSS=$(P0_TIMESERVER_CROSS) DEST=$(STAGING_DIR)/raumfeld CROSS_PREFIX=$(P0_TIMESERVER_CROSS_PREFIX)


$(TARGET_DIR)/$(P0_TIMESERVER_BINARY): $(STAGING_DIR)/$(P0_TIMESERVER_BINARY)
	$(MAKE) -C $(P0_TIMESERVER_DIR) CROSS=$(P0_TIMESERVER_CROSS) DEST=$(TARGET_DIR)/raumfeld CROSS_PREFIX=$(P0_TIMESERVER_CROSS_PREFIX)
	$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/$(P0_TIMESERVER_BINARY)

p0-timeserver: $(P0_TIMESERVER_DEPENDENCIES) $(TARGET_DIR)/$(P0_TIMESERVER_BINARY)

p0-timeserver-clean:
	rm -rf $(STAGING_DIR)/$(P0_TIMESERVER_TARGET_DIR)
	rm -rf $(TARGET_DIR)/$(P0_TIMESERVER_TARGET_DIR)
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
