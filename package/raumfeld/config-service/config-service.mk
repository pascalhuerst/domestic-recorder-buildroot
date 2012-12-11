#############################################################
#
# config-service
#
#############################################################

CONFIG_SERVICE_DEPENDENCIES = host-pkgconf libraumfeld libraumfeldcpp

$(eval $(raumfeld-cross-package))
