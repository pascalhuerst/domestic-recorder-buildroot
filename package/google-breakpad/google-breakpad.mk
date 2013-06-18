#############################################################
#
# google-breakpad
#
#############################################################
GOOGLE_BREAKPAD_VERSION = 1191
GOOGLE_BREAKPAD_SITE = http://google-breakpad.googlecode.com/svn/trunk
GOOGLE_BREAKPAD_SITE_METHOD = svn

GOOGLE_BREAKPAD_CONF_OPT = --disable-processor --disable-tools

$(eval $(autotools-package))
