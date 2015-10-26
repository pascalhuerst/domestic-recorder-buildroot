#############################################################
#
# timeserver
#
#############################################################

TIMESERVER_DEPENDENCIES = libraumfeld

RAUMFELD_TOPLEVEL_INSTALL=YES

$(eval $(raumfeld-cmake-package))
