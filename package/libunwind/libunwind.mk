#############################################################
#
# libunwind
#
#############################################################

LIBUNWIND_VERSION = 1.0-rc1
LIBUNWIND_SITE = http://download.savannah.gnu.org/releases/libunwind/
LIBUNWIND_INSTALL_STAGING = YES

LIBUNWIND_CONF_OPT = --enable-debug-frame

$(eval $(call AUTOTARGETS,package,libunwind))
