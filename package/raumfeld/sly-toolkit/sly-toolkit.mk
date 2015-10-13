#############################################################
#
# sly-toolkit
#
#############################################################

SLY_TOOLKIT_INSTALL_STAGING = YES

SLY_TOOLKIT_DEPENDENCIES = libglib2 directfb

$(eval $(raumfeld-cmake-package))
