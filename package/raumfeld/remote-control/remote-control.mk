#############################################################
#
# remote-control
#
#############################################################

define REMOTE_CONTROL_GLIB_GETTEXTIZE
	(cd $(@D); $(HOST_DIR)/usr/bin/glib-gettextize)
endef

REMOTE_CONTROL_POST_PATCH_HOOKS += REMOTE_CONTROL_GLIB_GETTEXTIZE

REMOTE_CONTROL_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(HOST_DIR)/usr/bin/glib-genmarshal \
	ac_cv_path_GLIB_MKENUMS=$(HOST_DIR)/usr/bin/glib-mkenums \
	gt_cv_func_gnugettext1_libintl=yes

REMOTE_CONTROL_CONF_OPT = \
	--disable-glibtest

REMOTE_CONTROL_DEPENDENCIES = host-pkgconf host-libglib2 gettext iso-codes libraumfeld sly-toolkit

$(eval $(raumfeld-autotools-package))
