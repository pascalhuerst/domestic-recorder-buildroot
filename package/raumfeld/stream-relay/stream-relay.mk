#############################################################
#
# stream-relay
#
#############################################################

STREAM_RELAY_DEPENDENCIES = host-pkg-config libraumfeld libraumfeldcpp libmms libvorbis taglib

$(eval $(raumfeld-cross-package))
