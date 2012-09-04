#############################################################
#
# p0-timeserver
#
#############################################################

P0_TIMESERVER_DEPENDENCIES = host-pkg-config libraumfeld

$(eval $(raumfeld-cross-package))
