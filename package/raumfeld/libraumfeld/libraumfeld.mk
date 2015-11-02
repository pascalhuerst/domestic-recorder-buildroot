#############################################################
#
# libraumfeld
#
#############################################################

LIBRAUMFELD_INSTALL_STAGING = YES

ifeq ($(BR2_PACKAGE_LIBRAUMFELD_PROFILING),y)
LIBRAUMFELD_CONF_OPTS += -DENABLE_PROFILING=1
endif

LIBRAUMFELD_DEPENDENCIES = \
	avahi gupnp-av openssl libglib2 libarchive libunwind yajl

$(eval $(raumfeld-cmake-package))
