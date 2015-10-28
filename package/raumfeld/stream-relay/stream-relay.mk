#############################################################
#
# stream-relay
#
#############################################################

STREAM_RELAY_DEPENDENCIES = host-intltool host-pkgconf libraumfeld libraumfeldcpp libasf libmms libvorbis taglib

$(eval $(raumfeld-cross-package))
