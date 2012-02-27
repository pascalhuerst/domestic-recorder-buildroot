#############################################################
#
# libffi
#
#############################################################

LIBFFI_VERSION = 3.0.10
LIBFFI_SITE = ftp://sourceware.org/pub/libffi

LIBFFI_INSTALL_STAGING = YES

$(eval $(call AUTOTARGETS))
$(eval $(call AUTOTARGETS,host))

