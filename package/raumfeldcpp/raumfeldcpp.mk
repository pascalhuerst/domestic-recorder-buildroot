#############################################################
#
# raumfeldcpp
#
#############################################################

RAUMFELDCPP_VERSION = $(BR2_PACKAGE_RAUMFELDCPP_BRANCH)
RAUMFELDCPP_AUTORECONF = YES
RAUMFELDCPP_LIBTOOL_PATCH = NO
RAUMFELDCPP_INSTALL_STAGING = YES
RAUMFELDCPP_INSTALL_TARGET = YES

RAUMFELDCPP_CONF_OPT = \
	--enable-shared		\
	--enable-static		\
	--disable-explicit-deps \
	--disable-glibtest

RAUMFELDCPP_DEPENDENCIES = libsoup raumfeld

$(eval $(call AUTOTARGETS,package,raumfeldcpp))

$(RAUMFELDCPP_DIR)/.bzr:
	if ! test -d $(RAUMFELDCPP_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/raumfeldcpp/$(RAUMFELDCPP_VERSION) raumfeldcpp-$(RAUMFELDCPP_VERSION)) \
	fi

$(RAUMFELDCPP_DIR)/.stamp_downloaded: $(RAUMFELDCPP_DIR)/.bzr
	touch $@

$(RAUMFELDCPP_DIR)/.stamp_extracted: $(RAUMFELDCPP_DIR)/.stamp_downloaded
	touch $@
