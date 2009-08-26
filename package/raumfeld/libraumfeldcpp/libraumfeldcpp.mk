#############################################################
#
# libraumfeldcpp
#
#############################################################

LIBRAUMFELDCPP_VERSION = $(BR2_PACKAGE_RAUMFELD_BRANCH)
LIBRAUMFELDCPP_AUTORECONF = YES
LIBRAUMFELDCPP_LIBTOOL_PATCH = NO
LIBRAUMFELDCPP_INSTALL_STAGING = YES
LIBRAUMFELDCPP_INSTALL_TARGET = YES

LIBRAUMFELDCPP_CONF_OPT = \
	--enable-shared		\
	--enable-static		\
	--disable-explicit-deps \
	--disable-glibtest

LIBRAUMFELDCPP_DEPENDENCIES = libsoup libraumfeld

$(eval $(call AUTOTARGETS,package/raumfeld,libraumfeldcpp))

$(LIBRAUMFELDCPP_DIR)/.bzr:
	if ! test -d $(LIBRAUMFELDCPP_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/raumfeldcpp/$(LIBRAUMFELDCPP_VERSION) libraumfeldcpp-$(LIBRAUMFELDCPP_VERSION)) \
	fi

$(LIBRAUMFELDCPP_DIR)/.stamp_downloaded: $(LIBRAUMFELDCPP_DIR)/.bzr
	touch $@

$(LIBRAUMFELDCPP_DIR)/.stamp_extracted: $(LIBRAUMFELDCPP_DIR)/.stamp_downloaded
	touch $@
