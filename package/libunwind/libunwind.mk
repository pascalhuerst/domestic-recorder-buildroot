#############################################################
#
# libunwind
#
#############################################################

LIBUNWIND_VERSION = 1.1
LIBUNWIND_SITE = http://download.savannah.gnu.org/releases/libunwind/
LIBUNWIND_INSTALL_STAGING = YES

$(eval $(autotools-package))
