#############################################################
#
# gupnp
#
#############################################################

GUPNP_VERSION:=0.12.8
GUPNP_SOURCE:=gupnp-$(GUPNP_VERSION).tar.gz
GUPNP_SITE:=http://www.gupnp.org/sources/gupnp
GUPNP_AUTORECONF = NO
GUPNP_LIBTOOL_PATCH = NO
GUPNP_INSTALL_STAGING = YES
GUPNP_INSTALL_TARGET = YES

GUPNP_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(HOST_GLIB)/bin/glib-genmarshal

GUPNP_CONF_OPT = \
	--enable-shared		\
	--enable-static		\
	--disable-explicit-deps \
	--disable-glibtest	\
	--disable-gtk-doc --without-html-dir

GUPNP_DEPENDENCIES = uclibc host-pkgconfig libuuid libglib2 libxml2 gssdp

$(eval $(call AUTOTARGETS,package,gupnp))
