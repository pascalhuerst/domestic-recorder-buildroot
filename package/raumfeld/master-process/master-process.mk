#############################################################
#
# master-process
#
#############################################################

MASTER_PROCESS_DEPENDENCIES = libraumfeldcpp

RAUMFELD_TOPLEVEL_INSTALL=YES

$(eval $(raumfeld-cmake-package))
