#############################################################
#
# libraumfelddsp
#
#############################################################

LIBRAUMFELDDSP_INSTALL_STAGING = YES

LIBRAUMFELDDSP_CONF_OPT = \
	--enable-shared		\
	--disable-explicit-deps \
	--disable-glibtest

LIBRAUMFELDDSP_DEPENDENCIES = host-pkgconf flac libraumfeldcpp

$(eval $(raumfeld-autotools-package))
