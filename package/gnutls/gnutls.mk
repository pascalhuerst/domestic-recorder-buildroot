#############################################################
#
# gnutls
#
#############################################################

GNUTLS_VERSION = 2.12.18
GNUTLS_SOURCE = gnutls-$(GNUTLS_VERSION).tar.bz2
GNUTLS_SITE = http://ftp.gnu.org/gnu/gnutls/
GNUTLS_DEPENDENCIES = libgcrypt
GNUTLS_CONF_OPT += --disable-cxx --with-libgcrypt --without-libgcrypt-prefix --without-p11-kit
GNUTLS_INSTALL_STAGING = YES

$(eval $(call AUTOTARGETS))
