#############################################################
#
# web-service
#
#############################################################

WEB_SERVICE_DEPENDENCIES = host-intltool host-pkgconf host-libglib2 libraumfeld libraumfeldcpp

$(eval $(raumfeld-cross-package))
