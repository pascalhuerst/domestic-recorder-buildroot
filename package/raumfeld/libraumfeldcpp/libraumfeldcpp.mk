#############################################################
#
# libraumfeldcpp
#
#############################################################

LIBRAUMFELDCPP_INSTALL_STAGING = YES

LIBRAUMFELDCPP_DEPENDENCIES = libsoup libraumfeld spotify-embedded

$(eval $(raumfeld-cmake-package))
