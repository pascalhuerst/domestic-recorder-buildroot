#############################################################
#
# gupnp-igd
#
#############################################################

GUPNP_IGD_VERSION = 0.1.6
GUPNP_IGD_SOURCE = gupnp-igd-$(GUPNP_IGD_VERSION).tar.gz
GUPNP_IGD_SITE = http://www.gupnp.org/sites/all/files/sources
GUPNP_IGD_INSTALL_STAGING = YES
GUPNP_IGD_INSTALL_TARGET = YES

GUPNP_IGD_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(LIBGLIB2_HOST_BINARY)

GUPNP_IGD_DEPENDENCIES = host-pkg-config gupnp

$(eval $(autotools-package))
