#############################################################
#
# LIBFAAD2
#
#############################################################

LIBFAAD2_VERSION:=2.7
LIBFAAD2_SOURCE:=faad2-$(LIBFAAD2_VERSION).tar.bz2
LIBFAAD2_SITE:=http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/faac
LIBFAAD2_AUTORECONF = NO
LIBFAAD2_INSTALL_STAGING = YES
LIBFAAD2_INSTALL_TARGET = YES

LIBFAAD2_CONF_OPT = \
	--enable-shared		\
	--enable-static		\
	--disable-explicit-deps \
	--disable-gtk-doc --without-html-dir

LIBFAAD2_DEPENDENCIES = uclibc

$(eval $(call AUTOTARGETS,package/multimedia,libfaad2))


