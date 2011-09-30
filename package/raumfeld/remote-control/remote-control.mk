#############################################################
#
# remote-control
#
#############################################################

REMOTE_CONTROL_VERSION = $(call qstrip,$(BR2_PACKAGE_RAUMFELD_BRANCH))
REMOTE_CONTROL_AUTORECONF = YES
REMOTE_CONTROL_LIBTOOL_PATCH = NO
REMOTE_CONTROL_INSTALL_STAGING = YES
REMOTE_CONTROL_INSTALL_TARGET = YES

REMOTE_CONTROL_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(HOST_DIR)/usr/bin/glib-genmarshal \
	ac_cv_path_GLIB_MKENUMS=$(HOST_DIR)/usr/bin/glib-mkenums \
	gt_cv_func_gnugettext1_libintl=yes

REMOTE_CONTROL_CONF_OPT = \
	--disable-glibtest

REMOTE_CONTROL_DEPENDENCIES = host-pkg-config host-libglib2 gettext libintl iso-codes libraumfeld sly-toolkit

$(eval $(call AUTOTARGETS))

$(REMOTE_CONTROL_DIR)/.bzr:
	if ! test -d $(REMOTE_CONTROL_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
	 	$(call qstrip,$(BR2_BZR_CO)) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/remote-control/$(REMOTE_CONTROL_VERSION) remote-control-$(REMOTE_CONTROL_VERSION)) \
	fi

$(REMOTE_CONTROL_DIR)/.stamp_downloaded: $(REMOTE_CONTROL_DIR)/.bzr
	touch $@

$(REMOTE_CONTROL_DIR)/.stamp_extracted: $(REMOTE_CONTROL_DIR)/.stamp_downloaded
	touch $@
