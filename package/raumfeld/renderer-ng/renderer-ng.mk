#############################################################
#
# renderer-ng
#
#############################################################

RENDERER_NG_DEPENDENCIES = host-pkgconf host-libglib2 alsa-lib flac libraumfeld libraumfeldcpp

$(eval $(raumfeld-cross-package))
