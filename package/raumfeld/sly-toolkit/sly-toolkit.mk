#############################################################
#
# sly-toolkit
#
#############################################################

SLY_TOOLKIT_INSTALL_STAGING = YES

SLY_TOOLKIT_CONF_ENV = \
	ac_cv_path_GLIB_GENMARSHAL=$(HOST_DIR)/usr/bin/glib-genmarshal \
	ac_cv_path_GLIB_MKENUMS=$(HOST_DIR)/usr/bin/glib-mkenums

SLY_TOOLKIT_CONF_OPT = \
	--enable-shared		\
	--disable-explicit-deps \
	--disable-glibtest	\
	--disable-gtk-doc --without-html-dir

SLY_TOOLKIT_DEPENDENCIES = host-pkgconf host-libglib2 libglib2 directfb

SLY_TOOLKIT_POST_EXTRACT_HOOKS = \
	(cd $(SLY_TOOLKIT_DIR); gtkdocize)

$(eval $(raumfeld-autotools-package))
