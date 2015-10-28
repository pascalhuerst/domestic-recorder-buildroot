#############################################################
#
# meta-server
#
#############################################################

META_SERVER_DEPENDENCIES = host-intltool libraumfeld libraumfeldcpp taglib yajl

$(eval $(raumfeld-cmake-package))
