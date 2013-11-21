#############################################################
#
# gupnp-igd
#
#############################################################

GUPNP_IGD_MAJOR_VERSION = 0.2
GUPNP_IGD_MINOR_VERSION = 2
GUPNP_IGD_VERSION = $(GUPNP_IGD_MAJOR_VERSION).$(GUPNP_IGD_MINOR_VERSION)
GUPNP_IGD_SOURCE = gupnp-igd-$(GUPNP_IGD_VERSION).tar.xz
GUPNP_IGD_SITE = http://ftp.gnome.org/pub/GNOME/sources/gupnp-igd/$(GUPNP_IGD_MAJOR_VERSION)
GUPNP_IGD_INSTALL_STAGING = YES

GUPNP_IGD_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(LIBGLIB2_HOST_BINARY)

GUPNP_IGD_DEPENDENCIES = host-pkgconf gupnp

$(eval $(autotools-package))
