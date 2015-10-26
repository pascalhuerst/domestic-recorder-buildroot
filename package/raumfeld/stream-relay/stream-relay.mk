#############################################################
#
# stream-relay
#
#############################################################

STREAM_RELAY_DEPENDENCIES = libraumfeld libraumfeldcpp libasf libmms libvorbis taglib

RAUMFELD_TOPLEVEL_INSTALL=YES

$(eval $(raumfeld-cmake-package))
