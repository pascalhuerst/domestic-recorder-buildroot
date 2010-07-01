#############################################################
#
# libsoup
#
#############################################################

LIBSOUP_MAJOR_VERSION:=2.30
LIBSOUP_VERSION:=$(LIBSOUP_MAJOR_VERSION).2
LIBSOUP_SOURCE:=libsoup-$(LIBSOUP_VERSION).tar.bz2
LIBSOUP_SITE:=http://ftp.gnome.org/pub/gnome/sources/libsoup/$(LIBSOUP_MAJOR_VERSION)
LIBSOUP_AUTORECONF = NO
LIBSOUP_LIBTOOL_PATCH = NO
LIBSOUP_INSTALL_STAGING = YES
LIBSOUP_INSTALL_TARGET = YES

LIBSOUP_CONF_ENV = \
		ac_cv_path_GLIB_GENMARSHAL=$(LIBGLIB2_HOST_BINARY)

ifneq ($(BR2_INET_IPV6),y)
LIBSOUP_CONF_ENV += soup_cv_ipv6=no
endif

ifeq ($(BR2_PACKAGE_LIBSOUP_SSL),y)
LIBSOUP_SSL_CONF_OPT = --enable-ssl
LIBSOUP_SSL_DEPENDENCIES = gnutls
else
LIBSOUP_SSL_CONF_OPT = --disable-ssl
endif

LIBSOUP_CONF_OPT = \
	--enable-shared		\
	--enable-static		\
	--disable-explicit-deps \
	--disable-glibtest	\
	$(LIBSOUP_SSL_CONF_OPT) \
	--without-gnome		\
	--disable-gtk-doc --without-html-dir

LIBSOUP_DEPENDENCIES = uclibc gettext libintl host-pkgconfig host-libglib2 libglib2 libxml2 $(LIBSOUP_SSL_DEPENDENCIES)

$(eval $(call AUTOTARGETS,package,libsoup))
