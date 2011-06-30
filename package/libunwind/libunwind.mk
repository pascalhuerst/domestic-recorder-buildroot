#############################################################
#
# libunwind
#
#############################################################

LIBUNWIND_VERSION:=e09f970
LIBUNWIND_SITE=git://git.sv.gnu.org/libunwind.git
LIBUNWIND_SITE_METHOD=git
LIBUNWIND_AUTORECONF = YES
LIBUNWIND_LIBTOOL_PATCH = NO
LIBUNWIND_INSTALL_STAGING = YES

LIBUNWIND_CONF_OPT = --enable-debug-frame

$(eval $(call AUTOTARGETS,package,libunwind))
