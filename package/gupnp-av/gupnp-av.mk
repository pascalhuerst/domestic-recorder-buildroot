#############################################################
#
# gupnp-av
#
#############################################################

GUPNP_AV_VERSION:=0.5.6
GUPNP_AV_SOURCE:=gupnp-av-$(GUPNP_AV_VERSION).tar.gz
GUPNP_AV_SITE:=http://www.gupnp.org/sources/gupnp-av
GUPNP_AV_AUTORECONF = NO
GUPNP_AV_LIBTOOL_PATCH = NO
GUPNP_AV_INSTALL_STAGING = YES
GUPNP_AV_INSTALL_TARGET = YES

GUPNP_AV_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(LIBGLIB2_HOST_BINARY)

GUPNP_AV_CONF_OPT = \
	--enable-shared		\
	--enable-static		\
	--disable-explicit-deps \
	--disable-glibtest	\
	--disable-gtk-doc --without-html-dir

GUPNP_AV_DEPENDENCIES = host-pkgconfig gupnp

$(eval $(call AUTOTARGETS,package,gupnp-av))
