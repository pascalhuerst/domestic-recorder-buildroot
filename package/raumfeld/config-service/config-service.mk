#############################################################
#
# config-service
#
#############################################################

CONFIG_SERVICE_DEPENDENCIES = host-pkg-config libraumfeld libraumfeldcpp

$(eval $(raumfeld-cross-package))
