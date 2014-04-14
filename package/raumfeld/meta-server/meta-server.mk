#############################################################
#
# meta-server
#
#############################################################

META_SERVER_DEPENDENCIES = host-pkgconf libraumfeld libraumfeldcpp taglib yajl

$(eval $(raumfeld-cross-package))
