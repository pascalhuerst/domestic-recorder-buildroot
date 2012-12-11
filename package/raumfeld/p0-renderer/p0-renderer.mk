#############################################################
#
# p0-renderer
#
#############################################################

P0_RENDERER_DEPENDENCIES = host-pkgconf host-libglib2 alsa-lib flac libraumfeld

$(eval $(raumfeld-cross-package))
