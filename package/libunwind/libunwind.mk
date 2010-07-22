#############################################################
#
# libunwind
#
#############################################################

LIBUNWIND_VERSION:=0.99
LIBUNWIND_SOURCE:=libunwind-$(LIBUNWIND_VERSION).tar.gz
LIBUNWIND_SITE:=http://download.savannah.nongnu.org/releases/libunwind/
LIBUNWIND_AUTORECONF = NO
LIBUNWIND_LIBTOOL_PATCH = NO
LIBUNWIND_INSTALL_STAGING = YES
LIBUNWIND_INSTALL_TARGET = YES

$(eval $(call AUTOTARGETS,package,libunwind))
