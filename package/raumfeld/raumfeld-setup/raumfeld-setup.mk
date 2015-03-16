#############################################################
#
# raumfeld-setup
#
#############################################################

RAUMFELD_SETUP_DEPENDENCIES = host-pkgconf host-libglib2 libraumfeldcpp

$(eval $(raumfeld-cross-package))
