#############################################################
#
# libraumfelddsp
#
#############################################################

LIBRAUMFELDDSP_INSTALL_STAGING = YES

LIBRAUMFELDDSP_CONF_OPTS = \
	--enable-shared		\
	--disable-explicit-deps \
	--disable-glibtest

LIBRAUMFELDDSP_DEPENDENCIES = host-pkgconf alsa-lib flac libraumfeldcpp

$(eval $(raumfeld-autotools-package))
