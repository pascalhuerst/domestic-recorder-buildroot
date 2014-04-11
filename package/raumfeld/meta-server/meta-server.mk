#############################################################
#
# meta-server
#
#############################################################

META_SERVER_DEPENDENCIES = host-pkgconf libraumfeld libraumfeldcpp taglib

$(eval $(raumfeld-cross-package))
