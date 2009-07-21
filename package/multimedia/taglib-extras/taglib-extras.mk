#############################################################
#
# taglib-extras
#
#############################################################
TAGLIB_EXTRAS_VERSION = 0.1.4
TAGLIB_EXTRAS_SOURCE = taglib-extras-$(TAGLIB_EXTRAS_VERSION).tar.gz
TAGLIB_EXTRAS_SITE = http://kollide.net/~jefferai

TAGLIB_EXTRAS_DIR = $(BUILD_DIR)/taglib-extras-$(TAGLIB_EXTRAS_VERSION)
TAGLIB_EXTRAS_SOVER = 0.1.0


$(DL_DIR)/$(TAGLIB_EXTRAS_SOURCE):
	$(call DOWNLOAD,$(TAGLIB_EXTRAS_SITE),$(TAGLIB_EXTRAS_SOURCE))

$(TAGLIB_EXTRAS_DIR)/.unpacked: $(DL_DIR)/$(TAGLIB_EXTRAS_SOURCE)
	$(ZCAT) $(DL_DIR)/$(TAGLIB_EXTRAS_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

$(TAGLIB_EXTRAS_DIR)/.configured: $(TAGLIB_EXTRAS_DIR)/.unpacked
	(cd $(TAGLIB_EXTRAS_DIR); rm -rf CMakeCache.txt; \
	 cmake -DCMAKE_FIND_ROOT_PATH=$(STAGING_DIR) \
              -DCMAKE_INSTALL_PREFIX=$(STAGING_DIR)/usr \
              -DCMAKE_C_COMPILER=$(TARGET_CC) \
              -DCMAKE_CXX_COMPILER=$(TARGET_CXX) .)
	touch $@

$(TAGLIB_EXTRAS_DIR)/taglib-extras/libtag-extras.so.$(TAGLIB_EXTRAS_SOVER): $(TAGLIB_EXTRAS_DIR)/.configured
	$(MAKE) -C $(TAGLIB_EXTRAS_DIR) $(TAGLIB_EXTRAS_MAKEOPTS)

$(STAGING_DIR)/usr/lib/libtag-extras.so: $(TAGLIB_EXTRAS_DIR)/taglib-extras/libtag-extras.so.$(TAGLIB_EXTRAS_SOVER)
	$(MAKE) -C $(TAGLIB_EXTRAS_DIR) $(TAGLIB_EXTRAS_MAKEOPTS) install

$(TARGET_DIR)/usr/lib/libtag-extras.so: $(STAGING_DIR)/usr/lib/libtag-extras.so
	cp -dpf $(STAGING_DIR)/usr/lib/libtag-extras.so* $(TARGET_DIR)/usr/lib/
	-$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/lib/libtag-extras.so

taglib-extras: uclibc taglib $(TARGET_DIR)/usr/lib/libtag-extras.so

taglib-extras-source: $(DL_DIR)/$(TAGLIB_EXTRAS_SOURCE)

taglib-extras-clean:
	-$(MAKE) -C $(TAGLIB_EXTRAS_DIR) $(TAGLIB_EXTRAS_MAKEOPTS) clean

taglib-extras-dirclean:
	rm -rf $(TAGLIB_EXTRAS_DIR)


#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_TAGLIB_EXTRAS),y)
TARGETS += taglib-extras
endif
