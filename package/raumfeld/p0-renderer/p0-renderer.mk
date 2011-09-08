#############################################################
#
# p0-renderer
#
#############################################################
P0_RENDERER_VERSION:=$(call qstrip,$(BR2_PACKAGE_RAUMFELD_BRANCH))
P0_RENDERER_DIR:=$(BUILD_DIR)/p0-renderer-$(P0_RENDERER_VERSION)
P0_RENDERER_TARGET_DIR:=raumfeld/p0-renderer
P0_RENDERER_BINARY:=$(P0_RENDERER_TARGET_DIR)/p0-renderer
P0_RENDERER_CROSS_PREFIX:=$(BASE_DIR)

P0_RENDERER_DEPENDENCIES = host-pkg-config host-libglib2 host-dbus-glib alsa-lib dbus-glib flac libraumfeld

ifeq ($(ARCH),arm)
P0_RENDERER_CROSS = ARM
endif

ifeq ($(ARCH),i586)
P0_RENDERER_CROSS = GEODE
endif

$(P0_RENDERER_DIR)/.bzr:
	test ! -z "$(P0_RENDERER_CROSS)" || \
		(echo "renderer can only be built for ARM or GEODE"; exit -1)
	if ! test -d $(P0_RENDERER_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
		mkdir -p p0-renderer-$(P0_RENDERER_VERSION); \
	 	$(call qstrip,$(BR2_BZR_CO)) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/p0-renderer/$(P0_RENDERER_VERSION) p0-renderer-$(P0_RENDERER_VERSION)) \
	fi
	touch -c $@

p0-renderer-source: $(P0_RENDERER_DIR)/.bzr 

$(STAGING_DIR)/$(P0_RENDERER_BINARY): p0-renderer-source
	PATH=$(TARGET_PATH) $(MAKE) -C $(P0_RENDERER_DIR) CROSS=$(P0_RENDERER_CROSS) DEST=$(STAGING_DIR)/raumfeld CROSS_PREFIX=$(P0_RENDERER_CROSS_PREFIX)

$(TARGET_DIR)/$(P0_RENDERER_BINARY): $(STAGING_DIR)/$(P0_RENDERER_BINARY)
	PATH=$(TARGET_PATH) $(MAKE) -C $(P0_RENDERER_DIR) CROSS=$(P0_RENDERER_CROSS) DEST=$(TARGET_DIR)/raumfeld CROSS_PREFIX=$(P0_RENDERER_CROSS_PREFIX)

p0-renderer: $(P0_RENDERER_DEPENDENCIES) $(TARGET_DIR)/$(P0_RENDERER_BINARY)

p0-renderer-clean:
	rm -rf $(STAGING_DIR)/$(P0_RENDERER_TARGET_DIR)
	rm -rf $(TARGET_DIR)/$(P0_RENDERER_TARGET_DIR)
	-$(MAKE) -C $(P0_RENDERER_DIR) clean CROSS=$(P0_RENDERER_CROSS)

p0-renderer-dirclean:
	rm -rf $(P0_RENDERER_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################	
ifeq ($(BR2_PACKAGE_RAUMFELD_RENDERER),y)
TARGETS+=p0-renderer
endif
