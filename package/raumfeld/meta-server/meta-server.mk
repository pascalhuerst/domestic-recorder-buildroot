#############################################################
#
# meta-server
#
#############################################################

META_SERVER_DEPENDENCIES = host-pkgconf libraumfeld libraumfeldcpp iso-codes sqlite taglib

$(eval $(raumfeld-cross-package))
