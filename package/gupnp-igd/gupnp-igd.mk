#############################################################
#
# gupnp-igd
#
#############################################################

GUPNP_IGD_VERSION:=0.1.3
GUPNP_IGD_SOURCE:=gupnp-igd-$(GUPNP_IGD_VERSION).tar.gz
GUPNP_IGD_SITE:=http://www.gupnp.org/sources/gupnp-igd
GUPNP_IGD_AUTORECONF = NO
GUPNP_IGD_LIBTOOL_PATCH = NO
GUPNP_IGD_INSTALL_STAGING = YES
GUPNP_IGD_INSTALL_TARGET = YES

GUPNP_IGD_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(LIBGLIB2_HOST_BINARY)

GUPNP_IGD_CONF_OPT = \
	--enable-shared		\
	--enable-static		\
	--disable-explicit-deps \
	--disable-glibtest	\
	--disable-gtk-doc --without-html-dir

GUPNP_IGD_DEPENDENCIES = host-pkgconfig gupnp

$(eval $(call AUTOTARGETS,package,gupnp-igd))


