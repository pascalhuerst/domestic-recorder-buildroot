#############################################################
#
# renderer
#
#############################################################

RENDERER_NG_DEPENDENCIES = host-pkgconf host-libglib2 alsa-lib flac kmod libraumfelddsp spotify-embedded

$(eval $(raumfeld-cross-package))
