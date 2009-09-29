#############################################################
#
# loopbacktest
#
#############################################################
LOOPBACKTEST_VERSION:=$(call qstrip,$(BR2_PACKAGE_RAUMFELD_BRANCH))
LOOPBACKTEST_DIR:=$(BUILD_DIR)/loopbacktest-$(LOOPBACKTEST_VERSION)
LOOPBACKTEST_TARGET_DIR:=raumfeld/p0-audiotest
LOOPBACKTEST_BINARY:=$(LOOPBACKTEST_TARGET_DIR)/p0-audiotest
LOOPBACKTEST_CROSS_PREFIX:=$(BUILD_DIR)/..

LOOPBACKTEST_DEPENDENCIES = host-pkgconfig alsa-lib liboil libglib2

ifeq ($(ARCH),arm)
LOOPBACKTEST_CROSS=ARM
else
echo "loopbacktest can only be build for ARM"
exit 1
endif

$(LOOPBACKTEST_DIR)/.bzr:
	if ! test -d $(LOOPBACKTEST_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
		mkdir -p loopbacktest-$(LOOPBACKTEST_VERSION); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/p0-renderer loopbacktest-$(LOOPBACKTEST_VERSION)) \
	fi
	touch -c $@

loopbacktest-source: $(LOOPBACKTEST_DIR)/.bzr 

$(STAGING_DIR)/$(LOOPBACKTEST_BINARY): loopbacktest-source
	$(MAKE) -C $(LOOPBACKTEST_DIR)/test CROSS=$(LOOPBACKTEST_CROSS) DEST=$(STAGING_DIR)/raumfeld CROSS_PREFIX=$(LOOPBACKTEST_CROSS_PREFIX)

$(TARGET_DIR)/$(LOOPBACKTEST_BINARY): $(STAGING_DIR)/$(LOOPBACKTEST_BINARY)
	$(MAKE) -C $(LOOPBACKTEST_DIR)/test CROSS=$(LOOPBACKTEST_CROSS) DEST=$(TARGET_DIR)/raumfeld CROSS_PREFIX=$(LOOPBACKTEST_CROSS_PREFIX)
	$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/$(LOOPBACKTEST_BINARY)

loopbacktest: $(LOOPBACKTEST_DEPENDENCIES) $(TARGET_DIR)/$(LOOPBACKTEST_BINARY)

loopbacktest-clean:
	rm -rf $(STAGING_DIR)/$(LOOPBACKTEST_TARGET_DIR)
	rm -rf $(STAGING_DIR)/$(TARGET_DIR)
	-$(MAKE) -C $(LOOPBACKTEST_DIR) clean CROSS=$(LOOPBACKTEST_CROSS)

loopbacktest-dirclean:
	rm -rf $(LOOPBACKTEST_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################	
ifeq ($(BR2_PACKAGE_RAUMFELD_LOOPBACKTEST),y)
TARGETS+=loopbacktest
endif
