#############################################################
#
# libraumfeldcpp
#
#############################################################

LIBRAUMFELDCPP_INSTALL_STAGING = YES

LIBRAUMFELDCPP_DEPENDENCIES = libsoup libraumfeld

$(eval $(raumfeld-dummy-package))
