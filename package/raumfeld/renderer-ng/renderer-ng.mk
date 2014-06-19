#############################################################
#
# renderer-ng
#
#############################################################

RENDERER_NG_DEPENDENCIES = host-pkgconf host-libglib2 alsa-lib flac libraumfelddsp spotify-embedded

$(eval $(raumfeld-cross-package))
