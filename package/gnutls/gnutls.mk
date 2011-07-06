#############################################################
#
# gnutls
#
#############################################################

GNUTLS_VERSION = 2.10.3
GNUTLS_SOURCE = gnutls-$(GNUTLS_VERSION).tar.bz2
GNUTLS_SITE = ftp://ftp.gnutls.org/pub/gnutls
GNUTLS_LIBTOOL_PATCH = YES
GNUTLS_INSTALL_STAGING = YES
GNUTLS_INSTALL_TARGET = YES

GNUTLS_DEPENDENCIES = host-pkg-config libglib2 libgcrypt

GNUTLS_CONF_OPT = \
	--with-libgcrypt-prefix=$(STAGING_DIR)/usr

$(eval $(call AUTOTARGETS,package,gnutls))
