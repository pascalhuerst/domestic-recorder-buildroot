##############################################################
#
# nettle
#
#############################################################

NETTLE_VERSION = 2.1
NETTLE_SOURCE = nettle-$(NETTLE_VERSION).tar.gz
NETTLE_SITE =ftp://ftp.lysator.liu.se/pub/security/lsh/
NETTLE_INSTALL_STAGING = YES

NETTLE_DEPENDENCIES = gmp

NETTLE_CONF_ENV = LIBS=-lm

$(eval $(call AUTOTARGETS,package,nettle))
