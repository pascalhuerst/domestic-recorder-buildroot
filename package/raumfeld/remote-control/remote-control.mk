#############################################################
#
# remote-control
#
#############################################################

REMOTE_CONTROL_INTLTOOLIZE = YES

REMOTE_CONTROL_DEPENDENCIES = host-intltool $(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),gettext) libraumfeld sly-toolkit

$(eval $(raumfeld-cmake-package))
