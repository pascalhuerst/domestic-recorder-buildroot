#############################################################
#
# raumfeld-extract
#
#############################################################

RAUMFELD_EXTRACT_VERSION = $(call qstrip,$(BR2_PACKAGE_RAUMFELD_BRANCH))
RAUMFELD_EXTRACT_AUTORECONF = YES
RAUMFELD_EXTRACT_LIBTOOL_PATCH = NO
RAUMFELD_EXTRACT_INSTALL_TARGET = YES

RAUMFELD_EXTRACT_DEPENDENCIES = libarchive

$(eval $(call AUTOTARGETS,package/raumfeld,raumfeld-extract))

$(RAUMFELD_EXTRACT_DIR)/.bzr:
	if ! test -d $(RAUMFELD_EXTRACT_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/raumfeld-extract/$(RAUMFELD_EXTRACT_VERSION) raumfeld-extract-$(RAUMFELD_EXTRACT_VERSION)) \
	fi

$(RAUMFELD_EXTRACT_DIR)/.stamp_downloaded: $(RAUMFELD_EXTRACT_DIR)/.bzr
	touch $@

$(RAUMFELD_EXTRACT_DIR)/.stamp_extracted: $(RAUMFELD_EXTRACT_DIR)/.stamp_downloaded
	touch $@
