#############################################################
#
# gnutls
#
#############################################################

GNUTLS_VERSION = 2.12.7
GNUTLS_SOURCE = gnutls-$(GNUTLS_VERSION).tar.bz2
GNUTLS_SITE = ftp://ftp.gnutls.org/pub/gnutls
GNUTLS_LIBTOOL_PATCH = YES
GNUTLS_INSTALL_STAGING = YES

GNUTLS_DEPENDENCIES = host-pkg-config libglib2 nettle

GNUTLS_CONF_ENV = LIBS=-ldl

$(eval $(call AUTOTARGETS,package,gnutls))
