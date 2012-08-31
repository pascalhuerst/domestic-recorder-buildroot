#############################################################
#
# LIBFAAD2
#
#############################################################

LIBFAAD2_VERSION = 2.7
LIBFAAD2_SOURCE = faad2-$(LIBFAAD2_VERSION).tar.bz2
LIBFAAD2_SITE = http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/faac
LIBFAAD2_INSTALL_STAGING = YES

LIBFAAD2_CONF_OPT = CFLAGS="-DFIXED_POINT"

$(eval $(autotools-package))


