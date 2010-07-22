#############################################################
#
# libunwind
#
#############################################################

LIBUNWIND_VERSION:=99e60be
LIBUNWIND_SOURCE:=libunwind-$(LIBUNWIND_VERSION).tar.gz
LIBUNWIND_URL:=http://git.savannah.gnu.org/gitweb/?p=libunwind.git;a=snapshot;h=$(LIBUNWIND_VERSION);sf=tgz
LIBUNWIND_AUTORECONF = YES
LIBUNWIND_LIBTOOL_PATCH = NO
LIBUNWIND_INSTALL_STAGING = YES
LIBUNWIND_INSTALL_TARGET = YES

LIBUNWIND_CONF_OPT = --enable-debug-frame

$(eval $(call AUTOTARGETS,package,libunwind))

$(LIBUNWIND_DIR)/.stamp_downloaded:
	$(WGET) -O $(DL_DIR)/$(LIBUNWIND_SOURCE) "$(LIBUNWIND_URL)"
	$(Q)mkdir -p $(LIBUNWIND_DIR)
	$(Q)touch $@
