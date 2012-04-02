#############################################################
#
# libsoup
#
#############################################################

LIBSOUP_MAJOR_VERSION = 2.38
LIBSOUP_MINOR_VERSION = 0
LIBSOUP_VERSION = $(LIBSOUP_MAJOR_VERSION).$(LIBSOUP_MINOR_VERSION)
LIBSOUP_SOURCE = libsoup-$(LIBSOUP_VERSION).tar.xz
LIBSOUP_SITE = http://ftp.gnome.org/pub/gnome/sources/libsoup/$(LIBSOUP_MAJOR_VERSION)
LIBSOUP_INSTALL_STAGING = YES

LIBSOUP_CONF_ENV = ac_cv_path_GLIB_GENMARSHAL=$(LIBGLIB2_HOST_BINARY)

ifneq ($(BR2_INET_IPV6),y)
LIBSOUP_CONF_ENV += soup_cv_ipv6=no
endif

LIBSOUP_CONF_OPT = --disable-glibtest --without-gnome

LIBSOUP_DEPENDENCIES = $(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),gettext libintl) host-pkg-config host-libglib2 libglib2 libxml2

ifeq ($(BR2_PACKAGE_LIBSOUP_SSL),y)
LIBSOUP_DEPENDENCIES += glib-networking
else
LIBSOUP_CONF_OPT += --disable-tls-check
endif

$(eval $(call AUTOTARGETS))
