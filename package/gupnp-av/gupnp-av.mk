#############################################################
#
# gupnp-av
#
#############################################################

GUPNP_AV_MAJOR_VERSION = 0.6
GUPNP_AV_MINOR_VERSION = 3
GUPNP_AV_VERSION = $(GUPNP_AV_MAJOR_VERSION).$(GUPNP_AV_MINOR_VERSION)
GUPNP_AV_SOURCE = gupnp-av-$(GUPNP_AV_VERSION).tar.bz2
GUPNP_AV_SITE = http://ftp.gnome.org/pub/GNOME/sources/gupnp-av/$(GUPNP_AV_MAJOR_VERSION)

GUPNP_AV_INSTALL_STAGING = YES

GUPNP_AV_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(LIBGLIB2_HOST_BINARY)

GUPNP_AV_DEPENDENCIES = host-pkgconf host-libglib2 gupnp

$(eval $(autotools-package))
