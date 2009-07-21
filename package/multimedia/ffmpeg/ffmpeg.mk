#############################################################
#
# ffmpeg
#
#############################################################
FFMPEG_VERSION := 0.5
FFMPEG_SOURCE := ffmpeg-$(FFMPEG_VERSION).tar.bz2
FFMPEG_SITE := http://ffmpeg.org/releases
FFMPEG_DIR := $(BUILD_DIR)/ffmpeg-$(FFMPEG_VERSION)

FFMPEG_LIBAVCODEC_SOVER = 52.20.0
FFMPEG_LIBAVFORMAT_SOVER = 52.31.0
FFMPEG_LIBAVUTIL_SOVER = 49.15.0
FFMPEG_LIBPOSTPROC = 51.2.0

FFMPEG_DEPENDENCIES = uclibc

FFMPEG_TARGET_LIBRARIES = \
	$(TARGET_DIR)/usr/lib/libavcodec.so	\
	$(TARGET_DIR)/usr/lib/libavformat.so	\
	$(TARGET_DIR)/usr/lib/libavutil.so	\
	$(TARGET_DIR)/usr/lib/libpostproc.so

FFMPEG_CONF_OPT = \
	--disable-ffmpeg	\
	--disable-ffplay	\
	--disable-ffserver	\
	--disable-avfilter	\
	--disable-swscale	\
	--disable-vhook		\

ifeq ($(BR2_PACKAGE_FFMPEG_GPL),y)
FFMPEG_CONF_OPT += --enable-gpl
else
FFMPEG_CONF_OPT += --disable-gpl
endif
		
ifeq ($(BR2_PACKAGE_FFMPEG_NONFREE),y)
FFMPEG_CONF_OPT += --enable-nonfree
else
FFMPEG_CONF_OPT += --disable-nonfree
endif

ifeq ($(BR2_PACKAGE_FFMPEG_POSTPROC),y)
FFMPEG_CONF_OPT += --enable-postproc
else
FFMPEG_CONF_OPT += --disable-postproc
endif

ifeq ($(BR2_PTHREADS_NONE),y)
FFMPEG_CONF_OPT += --disable-pthreads
else
FFMPEG_CONF_OPT += --enable-pthreads
endif

ifeq ($(BR2_INET_IPV6),y)
FFMPEG_CONF_OPT += --enable-ipv6
else
FFMPEG_CONF_OPT += --disable-ipv6
endif

ifeq ($(BR2_PACKAGE_ZLIB),y)
FFMPEG_CONF_OPT += --enable-zlib
FFMPEG_DEPENDENCIES += zlib
else
FFMPEG_CONF_OPT += --disable-zlib
endif

$(DL_DIR)/$(FFMPEG_SOURCE):
	$(call DOWNLOAD,$(FFMPEG_SITE),$(FFMPEG_SOURCE))

$(FFMPEG_DIR)/.unpacked: $(DL_DIR)/$(FFMPEG_SOURCE)
	$(BZCAT) $(DL_DIR)/$(FFMPEG_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

$(FFMPEG_DIR)/.configured: $(FFMPEG_DIR)/.unpacked
	(cd $(FFMPEG_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
		--enable-shared \
		--prefix=$(STAGING_DIR)/usr \
		--cross-prefix=$(TARGET_CROSS) \
		--enable-cross-compile \
		--sysroot=$(STAGING_DIR) \
		--host-cc=$(HOSTCC) \
		--cc=$(TARGET_CC) \
		--arch=$(BR2_ARCH) \
		--extra-cflags=-fPIC \
		$(FFMPEG_CONF_OPT) \
	)
	touch $@

$(FFMPEG_DIR)/libavcodec/libavcodec.so.$(FFMPEG_LIBAVCODEC_SOVER): $(FFMPEG_DIR)/.configured
	$(MAKE) -C $(FFMPEG_DIR)

$(FFMPEG_DIR)/libpostproc/libpostproc.so.$(FFMPEG_LIBPOSTPROC_SOVER): $(FFMPEG_DIR)/.configured
	$(MAKE) -C $(FFMPEG_DIR)

$(FFMPEG_DIR)/libavformat/libavformat.so.$(FFMPEG_LIBAVFORMAT_SOVER): $(FFMPEG_DIR)/.configured
	$(MAKE) -C $(FFMPEG_DIR)

$(FFMPEG_DIR)/libavutil/libavutil.so.$(FFMPEG_LIBAVUTIL_SOVER): $(FFMPEG_DIR)/.configured
	$(MAKE) -C $(FFMPEG_DIR)

$(STAGING_DIR)/usr/lib/libavcodec.so: $(FFMPEG_DIR)/libavcodec/libavcodec.so.$(FFMPEG_LIBAVCODEC_SOVER)
	$(MAKE) -C $(FFMPEG_DIR) install

$(STAGING_DIR)/usr/lib/libavformat.so: $(FFMPEG_DIR)/libavformat/libavformat.so.$(FFMPEG_LIBAVFORMAT_SOVER)
	$(MAKE) -C $(FFMPEG_DIR) install

$(STAGING_DIR)/usr/lib/libavutil.so: $(FFMPEG_DIR)/libavutil/libavutil.so.$(FFMPEG_LIBAVUTIL_SOVER)
	$(MAKE) -C $(FFMPEG_DIR) install

$(STAGING_DIR)/usr/lib/libpostproc.so: $(FFMPEG_DIR)/libpostproc/libpostproc.so.$(FFMPEG_LIBPOSTPROC_SOVER)
	$(MAKE) -C $(FFMPEG_DIR) install


$(TARGET_DIR)/usr/lib/libavcodec.so: $(STAGING_DIR)/usr/lib/libavcodec.so
	cp -dpf $(STAGING_DIR)/usr/lib/libavcodec.so* $(TARGET_DIR)/usr/lib/
	-$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/lib/libavcodec.so

$(TARGET_DIR)/usr/lib/libavformat.so: $(STAGING_DIR)/usr/lib/libavformat.so
	cp -dpf $(STAGING_DIR)/usr/lib/libavformat.so* $(TARGET_DIR)/usr/lib/
	-$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/lib/libavformat.so

$(TARGET_DIR)/usr/lib/libavutil.so: $(STAGING_DIR)/usr/lib/libavutil.so
	cp -dpf $(STAGING_DIR)/usr/lib/libavutil.so* $(TARGET_DIR)/usr/lib/
	-$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/lib/libavutil.so

$(TARGET_DIR)/usr/lib/libpostproc.so: $(STAGING_DIR)/usr/lib/libpostproc.so
	cp -dpf $(STAGING_DIR)/usr/lib/libpostproc.so* $(TARGET_DIR)/usr/lib/
	-$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(TARGET_DIR)/usr/lib/libpostproc.so


ffmpeg: $(FFMPEG_DEPENDENCIES) $(FFMPEG_TARGET_LIBRARIES)

ffmpeg-source: $(DL_DIR)/$(FFMPEG_SOURCE)

ffmpeg-unpacked: $(FFMPEG_DIR)/.unpacked

ffmpeg-clean:
	rm -f $(TARGET_DIR)/$(FFMPEG_TARGET_LIBRARIES)
	-$(MAKE) -C $(FFMPEG_DIR) clean

ffmpeg-dirclean:
	rm -rf $(FFMPEG_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_FFMPEG),y)
TARGETS += ffmpeg
endif
