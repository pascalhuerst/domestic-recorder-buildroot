#############################################################
#
# meta-server
#
#############################################################

META_SERVER_DEPENDENCIES = host-pkgconf libraumfeld libraumfeldcpp iso-codes taglib

$(eval $(raumfeld-cross-package))
