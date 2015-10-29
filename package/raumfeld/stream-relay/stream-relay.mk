#############################################################
#
# stream-relay
#
#############################################################

STREAM_RELAY_DEPENDENCIES = libraumfeld libraumfeldcpp libasf libmms libvorbis taglib

$(eval $(raumfeld-cmake-package))
