#############################################################
#
# web-service
#
#############################################################

WEB_SERVICE_DEPENDENCIES = host-intltool libraumfeld libraumfeldcpp

RAUMFELD_TOPLEVEL_INSTALL=YES

$(eval $(raumfeld-cmake-package))
