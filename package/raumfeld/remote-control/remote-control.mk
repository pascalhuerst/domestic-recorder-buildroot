#############################################################
#
# remote-control
#
#############################################################

REMOTE_CONTROL_GETTEXTIZE = YES

REMOTE_CONTROL_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(HOST_DIR)/usr/bin/glib-genmarshal \
	ac_cv_path_GLIB_MKENUMS=$(HOST_DIR)/usr/bin/glib-mkenums

REMOTE_CONTROL_CONF_OPT = --disable-glibtest

REMOTE_CONTROL_DEPENDENCIES = host-pkgconf host-libglib2 gettext iso-codes libraumfeld sly-toolkit

$(eval $(raumfeld-autotools-package))
