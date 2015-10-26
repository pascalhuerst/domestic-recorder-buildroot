#############################################################
#
# report-daemon
#
#############################################################

REPORT_DAEMON_DEPENDENCIES = libsoup

RAUMFELD_TOPLEVEL_INSTALL=YES

$(eval $(raumfeld-cmake-package))
