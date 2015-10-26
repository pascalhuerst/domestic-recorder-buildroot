#############################################################
#
# config-service
#
#############################################################

CONFIG_SERVICE_DEPENDENCIES = libraumfeld libraumfeldcpp

RAUMFELD_TOPLEVEL_INSTALL=YES

$(eval $(raumfeld-cmake-package))
