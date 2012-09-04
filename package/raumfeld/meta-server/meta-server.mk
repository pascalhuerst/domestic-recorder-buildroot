#############################################################
#
# meta-server
#
#############################################################

META_SERVER_DEPENDENCIES = host-pkg-config libraumfeld libraumfeldcpp iso-codes sqlite taglib

$(eval $(raumfeld-cross-package))
