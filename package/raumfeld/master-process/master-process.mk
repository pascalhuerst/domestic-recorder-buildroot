#############################################################
#
# master-process
#
#############################################################
MASTER_PROCESS_VERSION:=$(call qstrip,$(BR2_PACKAGE_RAUMFELD_BRANCH))
MASTER_PROCESS_DIR:=$(BUILD_DIR)/master-process-$(MASTER_PROCESS_VERSION)
MASTER_PROCESS_TARGET_DIR:=raumfeld/master-process
MASTER_PROCESS_BINARY:=$(MASTER_PROCESS_TARGET_DIR)/raumfeld-master-process
MASTER_PROCESS_CROSS_PREFIX:=$(BUILD_DIR)/..

MASTER_PROCESS_DEPENDENCIES = host-pkgconfig libraumfeld

ifeq ($(ARCH),arm)
MASTER_PROCESS_CROSS=ARM
else
ifeq ($(ARCH),i586)
MASTER_PROCESS_CROSS=GEODE
else
echo "master-process can only be build for ARM or GEODE"
exit 1
endif
endif

$(MASTER_PROCESS_DIR)/.bzr:
	if ! test -d $(MASTER_PROCESS_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
		mkdir -p master-process-$(MASTER_PROCESS_VERSION); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/master-process/$(MASTER_PROCESS_VERSION) master-process-$(MASTER_PROCESS_VERSION)) \
	fi
	touch -c $@

master-process-source: $(MASTER_PROCESS_DIR)/.bzr 

$(STAGING_DIR)/$(MASTER_PROCESS_BINARY): master-process-source
	$(MAKE) -C $(MASTER_PROCESS_DIR) CROSS=$(MASTER_PROCESS_CROSS) DEST=$(STAGING_DIR)/raumfeld CROSS_PREFIX=$(MASTER_PROCESS_CROSS_PREFIX)

$(TARGET_DIR)/$(MASTER_PROCESS_BINARY): $(STAGING_DIR)/$(MASTER_PROCESS_BINARY)
	$(MAKE) -C $(MASTER_PROCESS_DIR) CROSS=$(MASTER_PROCESS_CROSS) DEST=$(TARGET_DIR)/raumfeld CROSS_PREFIX=$(MASTER_PROCESS_CROSS_PREFIX)
	$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/$(MASTER_PROCESS_BINARY)

master-process: $(MASTER_PROCESS_DEPENDENCIES) $(TARGET_DIR)/$(MASTER_PROCESS_BINARY)

master-process-clean:
	rm -rf $(STAGING_DIR)/$(MASTER_PROCESS_TARGET_DIR)
	rm -rf $(STAGING_DIR)/$(TARGET_DIR)
	-$(MAKE) -C $(MASTER_PROCESS_DIR) clean CROSS=$(MASTER_PROCESS_CROSS)

master-process-dirclean:
	rm -rf $(MASTER_PROCESS_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_RAUMFELD_MASTER_PROCESS),y)
TARGETS+=master-process
endif
