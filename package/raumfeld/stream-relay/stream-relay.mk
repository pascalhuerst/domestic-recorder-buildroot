#############################################################
#
# stream-relay
#
#############################################################

STREAM_RELAY_DEPENDENCIES = host-pkgconf libraumfeld libraumfeldcpp libmms libvorbis taglib

$(eval $(raumfeld-cross-package))
