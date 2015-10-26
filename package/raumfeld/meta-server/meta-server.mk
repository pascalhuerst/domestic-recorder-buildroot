#############################################################
#
# meta-server
#
#############################################################

META_SERVER_DEPENDENCIES = host-intltool libraumfeld libraumfeldcpp taglib yajl

RAUMFELD_TOPLEVEL_INSTALL=YES

$(eval $(raumfeld-cmake-package))
