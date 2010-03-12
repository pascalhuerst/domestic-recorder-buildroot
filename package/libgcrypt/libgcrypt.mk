#############################################################
#
# libgcrypt
#
#############################################################

LIBGCRYPT_VERSION:=1.4.5
LIBGCRYPT_SOURCE:=libgcrypt-$(LIBGCRYPT_VERSION).tar.bz2
LIBGCRYPT_SITE:=ftp://ftp.freenet.de/pub/ftp.gnupg.org/gcrypt/libgcrypt/
LIBGCRYPT_INSTALL_STAGING:=YES

LIBGCRYPT_CONF_OPT = --disable-asm

LIBGCRYPT_DEPENDENCIES = libgpg-error

$(eval $(call AUTOTARGETS,package,libgcrypt))
