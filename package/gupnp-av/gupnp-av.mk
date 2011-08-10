#############################################################
#
# gupnp-av
#
#############################################################

GUPNP_AV_VERSION = 0.6.3
GUPNP_AV_SOURCE = gupnp-av-$(GUPNP_AV_VERSION).tar.gz
GUPNP_AV_SITE = http://www.gupnp.org/sites/all/files/sources
GUPNP_AV_INSTALL_STAGING = YES

GUPNP_AV_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(LIBGLIB2_HOST_BINARY)

GUPNP_AV_DEPENDENCIES = host-pkg-config host-libglib2 gupnp

$(eval $(call AUTOTARGETS,package,gupnp-av))
