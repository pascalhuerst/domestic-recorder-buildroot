#############################################################
#
# gupnp
#
#############################################################

GUPNP_VERSION:=0.14.1
GUPNP_SOURCE:=gupnp-$(GUPNP_VERSION).tar.gz
GUPNP_SITE:=http://www.gupnp.org/sites/all/files/sources
GUPNP_INSTALL_STAGING = YES
GUPNP_INSTALL_TARGET = YES

GUPNP_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(LIBGLIB2_HOST_BINARY)

GUPNP_CONF_OPT = \
	--enable-shared		\
	--enable-static		\
	--disable-explicit-deps \
	--disable-glibtest	\
	--disable-gtk-doc --without-html-dir

GUPNP_DEPENDENCIES = host-pkg-config host-libglib2 libxml2 gssdp util-linux

$(eval $(call AUTOTARGETS,package,gupnp))
