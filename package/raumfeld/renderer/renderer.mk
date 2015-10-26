#############################################################
#
# renderer
#
#############################################################

RENDERER_DEPENDENCIES = alsa-lib flac kmod libraumfelddsp spotify-embedded

RAUMFELD_TOPLEVEL_INSTALL=YES

$(eval $(raumfeld-cmake-package))
