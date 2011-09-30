#############################################################
#
# iso-codes
#
#############################################################
ISO_CODES_VERSION:=3.16
ISO_CODES_SOURCE:=iso-codes-$(ISO_CODES_VERSION).tar.bz2
ISO_CODES_SITE:=ftp://pkg-isocodes.alioth.debian.org/pub/pkg-isocodes/
ISO_CODES_INSTALL_STAGING = YES
ISO_CODES_INSTALL_TARGET = YES
ISO_CODES_DEPENDENCIES = gettext

$(eval $(call AUTOTARGETS))
