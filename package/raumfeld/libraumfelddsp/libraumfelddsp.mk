#############################################################
#
# libraumfelddsp
#
#############################################################

LIBRAUMFELDDSP_INSTALL_STAGING = YES

LIBRAUMFELDDSP_DEPENDENCIES = alsa-lib flac libraumfeldcpp

$(eval $(raumfeld-dummy-package))
