#############################################################
#
# renderer
#
#############################################################

RENDERER_DEPENDENCIES = alsa-lib flac kmod libraumfelddsp spotify-embedded

$(eval $(raumfeld-cmake-package))
