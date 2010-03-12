#############################################################
#
# gnutls
#
#############################################################

GNUTLS_VERSION:=2.8.5
GNUTLS_SOURCE:=gnutls-$(GNUTLS_VERSION).tar.bz2
GNUTLS_SITE:=ftp://ftp.gnutls.org/pub/gnutls
GNUTLS_AUTORECONF = NO
GNUTLS_LIBTOOL_PATCH = NO
GNUTLS_INSTALL_STAGING = YES
GNUTLS_INSTALL_TARGET = YES

GNUTLS_DEPENDENCIES = host-pkgconfig libglib2 libgcrypt

$(eval $(call AUTOTARGETS,package,gnutls))
