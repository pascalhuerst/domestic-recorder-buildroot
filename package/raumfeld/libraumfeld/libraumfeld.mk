#############################################################
#
# libraumfeld
#
#############################################################

LIBRAUMFELD_VERSION = $(BR2_PACKAGE_RAUMFELD_BRANCH)
LIBRAUMFELD_AUTORECONF = YES
LIBRAUMFELD_LIBTOOL_PATCH = NO
LIBRAUMFELD_INSTALL_STAGING = YES
LIBRAUMFELD_INSTALL_TARGET = YES

LIBRAUMFELD_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(HOST_GLIB)/bin/glib-genmarshal

LIBRAUMFELD_CONF_OPT = \
	--localstatedir=/var	\
	--enable-shared		\
	--disable-explicit-deps \
	--disable-glibtest	\
	--disable-gtk-doc --without-html-dir

LIBRAUMFELD_DEPENDENCIES = host-pkgconfig dbus-glib gupnp-av openssl

$(eval $(call AUTOTARGETS,package/raumfeld,libraumfeld))

$(LIBRAUMFELD_DIR)/.bzr:
	if ! test -d $(LIBRAUMFELD_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
	 	$(BZR_CO) $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/raumfeld/$(LIBRAUMFELD_VERSION) libraumfeld-$(LIBRAUMFELD_VERSION)) \
	fi

$(LIBRAUMFELD_DIR)/.stamp_downloaded: $(LIBRAUMFELD_DIR)/.bzr
	touch $@

$(LIBRAUMFELD_DIR)/.stamp_extracted: $(LIBRAUMFELD_DIR)/.stamp_downloaded
	(cd $(LIBRAUMFELD_DIR); gtkdocize)
	touch $@
