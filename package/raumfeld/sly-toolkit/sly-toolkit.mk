#############################################################
#
# sly-toolkit
#
#############################################################

SLY_TOOLKIT_VERSION = $(BR2_PACKAGE_RAUMFELD_BRANCH)
SLY_TOOLKIT_AUTORECONF = YES
SLY_TOOLKIT_LIBTOOL_PATCH = NO
SLY_TOOLKIT_INSTALL_STAGING = YES
SLY_TOOLKIT_INSTALL_TARGET = YES

SLY_TOOLKIT_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(HOST_GLIB)/bin/glib-genmarshal

SLY_TOOLKIT_CONF_OPT = \
	--enable-shared		\
	--disable-explicit-deps \
	--disable-glibtest	\
	--disable-gtk-doc --without-html-dir

SLY_TOOLKIT_DEPENDENCIES = host-pkgconfig libglib2 directfb

$(eval $(call AUTOTARGETS,package/raumfeld,sly-toolkit))

$(SLY_TOOLKIT_DIR)/.bzr:
	if ! test -d $(SLY_TOOLKIT_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/sly-toolkit/$(SLY_TOOLKIT_VERSION) sly-toolkit-$(SLY_TOOLKIT_VERSION)) \
	fi

$(SLY_TOOLKIT_DIR)/.stamp_downloaded: $(SLY_TOOLKIT_DIR)/.bzr
	touch $@

$(SLY_TOOLKIT_DIR)/.stamp_extracted: $(SLY_TOOLKIT_DIR)/.stamp_downloaded
	(cd $(SLY_TOOLKIT_DIR); gtkdocize)
	touch $@
