#############################################################
#
# report-daemon
#
#############################################################
REPORT_DAEMON_VERSION:=$(call qstrip,$(BR2_PACKAGE_RAUMFELD_BRANCH))
REPORT_DAEMON_DIR:=$(BUILD_DIR)/raumfeld-report-daemon-$(REPORT_DAEMON_VERSION)
REPORT_DAEMON_TARGET_DIR:=raumfeld/report-daemon
REPORT_DAEMON_BINARY:=$(REPORT_DAEMON_TARGET_DIR)/raumfeld-report-daemon
REPORT_DAEMON_CROSS_PREFIX:=$(BUILD_DIR)/..

REPORT_DAEMON_DEPENDENCIES = host-pkgconfig libsoup

ifeq ($(ARCH),arm)
REPORT_DAEMON_CROSS = ARM
endif

ifeq ($(ARCH),i586)
REPORT_DAEMON_CROSS = GEODE
endif

ifeq ($(ARCH),i386)
REPORT_DAEMON_CROSS = GEODE
endif

$(REPORT_DAEMON_DIR)/.bzr:
	test ! -z "$(REPORT_DAEMON_CROSS)" || \
		(echo "report-daemon can only be built for ARM or GEODE"; exit -1)
	if ! test -d $(REPORT_DAEMON_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
		mkdir -p raumfeld-report-daemon-$(REPORT_DAEMON_VERSION); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/raumfeld-report-daemon/$(REPORT_DAEMON_VERSION) raumfeld-report-daemon-$(REPORT_DAEMON_VERSION)) \
	fi
	touch -c $@

report-daemon-source: $(REPORT_DAEMON_DIR)/.bzr 

$(STAGING_DIR)/$(REPORT_DAEMON_BINARY): report-daemon-source
	$(MAKE) -C $(REPORT_DAEMON_DIR) CROSS=$(REPORT_DAEMON_CROSS) DEST=$(STAGING_DIR)/raumfeld CROSS_PREFIX=$(REPORT_DAEMON_CROSS_PREFIX)

$(TARGET_DIR)/$(REPORT_DAEMON_BINARY): $(STAGING_DIR)/$(REPORT_DAEMON_BINARY)
	$(MAKE) -C $(REPORT_DAEMON_DIR) CROSS=$(REPORT_DAEMON_CROSS) DEST=$(TARGET_DIR)/raumfeld CROSS_PREFIX=$(REPORT_DAEMON_CROSS_PREFIX)
	$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/$(REPORT_DAEMON_BINARY)

report-daemon: $(REPORT_DAEMON_DEPENDENCIES) $(TARGET_DIR)/$(REPORT_DAEMON_BINARY)

report-daemon-clean:
	rm -rf $(STAGING_DIR)/$(REPORT_DAEMON_TARGET_DIR)
	rm -rf $(STAGING_DIR)/$(TARGET_DIR)
	-$(MAKE) -C $(REPORT_DAEMON_DIR) clean CROSS=$(REPORT_DAEMON_CROSS)

report-daemon-dirclean:
	rm -rf $(REPORT_DAEMON_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_RAUMFELD_REPORT_DAEMON),y)
TARGETS+=report-daemon
endif
