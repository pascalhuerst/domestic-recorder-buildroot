#############################################################
#
# factory-tests
#
#############################################################

FACTORY_TESTS_DEPENDENCIES = host-pkgconf alsa-lib libraumfelddsp

$(eval $(raumfeld-cross-package))
