#############################################################
#
# libraumfeld
#
#############################################################

LIBRAUMFELD_INSTALL_STAGING = YES

LIBRAUMFELD_GTKDOCIZE = YES

LIBRAUMFELD_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(HOST_DIR)/usr/bin/glib-genmarshal \
	ac_cv_path_GLIB_MKENUMS=$(HOST_DIR)/usr/bin/glib-mkenums

LIBRAUMFELD_CONF_OPT = \
	--localstatedir=/var	\
	--enable-shared		\
	--disable-explicit-deps \
	--disable-glibtest	\
	--disable-gtk-doc --without-html-dir

ifeq ($(BR2_PACKAGE_LIBRAUMFELD_PROFILING),y)
LIBRAUMFELD_CONF_OPT += --enable-profiling
endif

LIBRAUMFELD_DEPENDENCIES = \
	host-pkgconf host-libglib2 avahi gupnp-av openssl libglib2 libarchive libunwind

$(eval $(raumfeld-autotools-package))
