#############################################################
#
# report-daemon
#
#############################################################

REPORT_DAEMON_MODULE = raumfeld-report-daemon

REPORT_DAEMON_DEPENDENCIES = host-pkg-config libsoup

$(eval $(raumfeld-cross-package))
