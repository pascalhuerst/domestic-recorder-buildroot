#############################################################
#
# gssdp
#
#############################################################

GSSDP_VERSION = 0.8.2
GSSDP_SOURCE = gssdp-$(GSSDP_VERSION).tar.gz
GSSDP_SITE = http://www.gupnp.org/sites/all/files/sources
GSSDP_INSTALL_STAGING = YES

GSSDP_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(LIBGLIB2_HOST_BINARY)

GSSDP_DEPENDENCIES = host-pkg-config host-libglib2 libsoup

$(eval $(call AUTOTARGETS))
