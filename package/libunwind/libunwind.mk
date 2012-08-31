#############################################################
#
# libunwind
#
#############################################################

LIBUNWIND_VERSION = 1.0.1
LIBUNWIND_SITE = http://download.savannah.gnu.org/releases/libunwind/
LIBUNWIND_AUTORECONF = YES
LIBUNWIND_INSTALL_STAGING = YES

$(eval $(autotools-package))
