#############################################################
#
# gupnp
#
#############################################################

GUPNP_MAJOR_VERSION = 0.20
GUPNP_MINOR_VERSION = 12
GUPNP_VERSION = $(GUPNP_MAJOR_VERSION).$(GUPNP_MINOR_VERSION)
GUPNP_SOURCE = gupnp-$(GUPNP_VERSION).tar.xz
GUPNP_SITE = http://ftp.gnome.org/pub/GNOME/sources/gupnp/$(GUPNP_MAJOR_VERSION)

GUPNP_INSTALL_STAGING = YES

GUPNP_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(LIBGLIB2_HOST_BINARY)

GUPNP_DEPENDENCIES = host-pkgconf host-libglib2 libxml2 gssdp util-linux

$(eval $(autotools-package))
