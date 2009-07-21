#############################################################
#
# gssdp
#
#############################################################

GSSDP_VERSION:=0.6.4
GSSDP_SOURCE:=gssdp-$(GSSDP_VERSION).tar.gz
GSSDP_SITE:=http://www.gupnp.org/sources/gssdp
GSSDP_AUTORECONF = NO
GSSDP_INSTALL_STAGING = YES
GSSDP_INSTALL_TARGET = YES

GSSDP_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(HOST_GLIB)/bin/glib-genmarshal

GSSDP_CONF_OPT = \
	--enable-shared		\
	--enable-static		\
	--disable-explicit-deps \
	--disable-glibtest	\
	--disable-gtk-doc --without-html-dir

GSSDP_DEPENDENCIES = uclibc host-pkgconfig libsoup

$(eval $(call AUTOTARGETS,package,gssdp))


