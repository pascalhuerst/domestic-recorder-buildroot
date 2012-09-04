#############################################################
#
# web-service
#
#############################################################

WEB_SERVICE_DEPENDENCIES = host-pkg-config host-libglib2 libraumfeld libraumfeldcpp

$(eval $(raumfeld-cross-package))
