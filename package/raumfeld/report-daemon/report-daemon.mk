#############################################################
#
# report-daemon
#
#############################################################

REPORT_DAEMON_DEPENDENCIES = host-pkgconf libsoup

$(eval $(raumfeld-cross-package))
