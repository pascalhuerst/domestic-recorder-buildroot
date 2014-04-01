#############################################################
#
# renderer-ng
#
#############################################################

RENDERER_NG_DEPENDENCIES = host-pkgconf host-libglib2 alsa-lib flac libraumfelddsp

$(eval $(raumfeld-cross-package))
