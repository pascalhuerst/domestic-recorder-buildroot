#############################################################
#
# raumfeld
#
#############################################################

RAUMFELD_VERSION = $(BR2_PACKAGE_RAUMFELD_BRANCH)
RAUMFELD_AUTORECONF = YES
RAUMFELD_LIBTOOL_PATCH = NO
RAUMFELD_INSTALL_STAGING = YES
RAUMFELD_INSTALL_TARGET = YES

RAUMFELD_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(HOST_GLIB)/bin/glib-genmarshal

RAUMFELD_CONF_OPT = \
	--enable-shared		\
	--enable-static		\
	--disable-explicit-deps \
	--disable-glibtest	\
	--disable-gtk-doc --without-html-dir

RAUMFELD_DEPENDENCIES = uclibc host-pkgconfig dbus-glib gupnp-av

$(eval $(call AUTOTARGETS,package,raumfeld))

$(RAUMFELD_DIR)/.bzr:
	if ! test -d $(RAUMFELD_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/raumfeld/$(RAUMFELD_VERSION) raumfeld-$(RAUMFELD_VERSION)) \
	fi

$(RAUMFELD_DIR)/.stamp_downloaded: $(RAUMFELD_DIR)/.bzr
	touch $@

$(RAUMFELD_DIR)/.stamp_extracted: $(RAUMFELD_DIR)/.stamp_downloaded
	(cd $(RAUMFELD_DIR); gtkdocize)
	touch $@
