#############################################################
#
# gssdp
#
#############################################################

GSSDP_MAJOR_VERSION = 0.14
GSSDP_MINOR_VERSION = 10
GSSDP_VERSION = $(GSSDP_MAJOR_VERSION).$(GSSDP_MINOR_VERSION)
GSSDP_SOURCE = gssdp-$(GSSDP_VERSION).tar.xz
GSSDP_SITE = http://ftp.gnome.org/pub/GNOME/sources/gssdp/$(GSSDP_MAJOR_VERSION)

GSSDP_INSTALL_STAGING = YES

GSSDP_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(LIBGLIB2_HOST_BINARY)

GSSDP_DEPENDENCIES = host-pkgconf host-libglib2 libsoup

$(eval $(autotools-package))
