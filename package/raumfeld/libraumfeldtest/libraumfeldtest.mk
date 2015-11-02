#############################################################
#
# libraumfeldtest
#
#############################################################

LIBRAUMFELDTEST_INSTALL_STAGING = YES

LIBRAUMFELDTEST_DEPENDENCIES = libraumfeldcpp

$(eval $(raumfeld-cmake-package))
