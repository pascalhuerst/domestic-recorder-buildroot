#############################################################
#
# remote-control
#
#############################################################

REMOTE_CONTROL_VERSION = $(BR2_PACKAGE_REMOTE_CONTROL_BRANCH)
REMOTE_CONTROL_AUTORECONF = YES
REMOTE_CONTROL_LIBTOOL_PATCH = NO
REMOTE_CONTROL_INSTALL_STAGING = YES
REMOTE_CONTROL_INSTALL_TARGET = YES

REMOTE_CONTROL_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(HOST_GLIB)/bin/glib-genmarshal

REMOTE_CONTROL_CONF_OPT = \
	--enable-shared		\
	--enable-static		\
	--disable-explicit-deps \
	--disable-glibtest

REMOTE_CONTROL_DEPENDENCIES = host-pkgconfig raumfeld sly-toolkit

$(eval $(call AUTOTARGETS,package,remote-control))

$(REMOTE_CONTROL_DIR)/.bzr:
	if ! test -d $(REMOTE_CONTROL_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/remote-control/$(REMOTE_CONTROL_VERSION) remote-control-$(REMOTE_CONTROL_VERSION)) \
	fi

$(REMOTE_CONTROL_DIR)/.stamp_downloaded: $(REMOTE_CONTROL_DIR)/.bzr
	touch $@

$(REMOTE_CONTROL_DIR)/.stamp_extracted: $(REMOTE_CONTROL_DIR)/.stamp_downloaded
	touch $@
