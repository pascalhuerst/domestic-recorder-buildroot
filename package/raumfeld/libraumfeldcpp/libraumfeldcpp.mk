#############################################################
#
# libraumfeldcpp
#
#############################################################

LIBRAUMFELDCPP_INSTALL_STAGING = YES

LIBRAUMFELDCPP_CONF_OPT = \
	--enable-shared		\
	--disable-explicit-deps \
	--disable-glibtest

LIBRAUMFELDCPP_DEPENDENCIES = host-pkgconf libsoup libraumfeld

$(eval $(raumfeld-autotools-package))
