#############################################################
#
# gst-ffmpeg
#
#############################################################
GST_FFMPEG_VERSION = 0.10.10
GST_FFMPEG_SOURCE = gst-ffmpeg-$(GST_FFMPEG_VERSION).tar.bz2
GST_FFMPEG_SITE = http://gstreamer.freedesktop.org/src/gst-ffmpeg
GST_FFMPEG_INSTALL_STAGING = YES
GST_FFMPEG_LIBTOOL_PATCH = NO
GST_FFMPEG_DIR := $(BUILD_DIR)/gst-ffmpeg-$(GST_FFMPEG_VERSION)
GST_FFMPEG_LIBRARY = libgstffmpeg.so
GST_FFMPEG_DESTDIR:=usr/lib/gstreamer-0.10
GST_FFMPEG_TARGET_LIBRARY = $(TARGET_DIR)/$(GST_FFMPEG_DESTDIR)/$(GST_FFMPEG_LIBRARY)
GST_FFMPEG_STAGING_LIBRARY = $(STAGING_DIR)/$(GST_FFMPEG_DESTDIR)/$(GST_FFMPEG_LIBRARY)

GST_FFMPEG_DEPENDENCIES = gstreamer gst-plugins-base

GST_FFMPEG_CONF_OPT = \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
		--with-ffmpeg-extra-configure="--target-os=linux \
						--disable-ffmpeg \
						--disable-ffplay \
						--disable-ffserver \
						--disable-avfilter \
						--disable-swscale \
						--disable-vhook  \
						--enable-gpl \
						--enable-nonfree \
						--enable-postproc \
						--enable-pthreads \
						--enable-zlib \
						--disable-avfilter \
						--enable-postproc \
						--enable-swscale \
						--prefix=$(STAGING_DIR)/usr \
						--enable-cross-compile \
						--sysroot=$(STAGING_DIR) \
						--host-cc=$(TARGET_CC) \
						--cc=$(TARGET_CC) \
						--arch=$(BR2_ARCH) \
						--enable-cross-compile \
						--cross-prefix=$(TARGET_CROSS) \
						--disable-shared \
						--enable-static \
            --disable-decoder=h264"

$(DL_DIR)/$(GST_FFMPEG_SOURCE):
	$(call DOWNLOAD,$(GST_FFMPEG_SITE),$(GST_FFMPEG_SOURCE))

$(GST_FFMPEG_DIR)/.unpacked: $(DL_DIR)/$(GST_FFMPEG_SOURCE)
	$(BZCAT) $(DL_DIR)/$(GST_FFMPEG_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

$(GST_FFMPEG_DIR)/.configured: $(GST_FFMPEG_DIR)/.unpacked
	(cd $(GST_FFMPEG_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		CFLAGS="$(TARGET_CFLAGS) -fPIC" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--sysconfdir=/etc \
		--enable-shared \
		--prefix=$(STAGING_DIR)/usr \
		$(GST_FFMPEG_CONF_OPT) \
	)
	touch $@

$(GST_FFMPEG_DIR)/ext/ffmpeg/$(GST_FFMPEG_LIBRARY): $(GST_FFMPEG_DIR)/.configured
	$(MAKE) -C $(GST_FFMPEG_DIR)

$(GST_FFMPEG_STAGING_LIBRARY): $(GST_FFMPEG_DIR)/ext/ffmpeg/$(GST_FFMPEG_LIBRARY)
	$(MAKE) -C $(GST_FFMPEG_DIR) install

$(GST_FFMPEG_TARGET_LIBRARY): $(GST_FFMPEG_STAGING_LIBRARY)
	cp -dpf $(STAGING_DIR)/$(GST_FFMPEG_DESTDIR)/libgstffmpeg.so* $(TARGET_DIR)/$(GST_FFMPEG_DESTDIR)
	-$(STRIPCMD) $(STRIP_STRIP_UNNEEDED) $(GST_FFMPEG_TARGET_LIBRARY)

gst-ffmpeg: $(GST_FFMPEG_DEPENDENCIES) $(GST_FFMPEG_TARGET_LIBRARY)

gst-ffmpeg-source: $(DL_DIR)/$(GST_FFMPEG_SOURCE)

gst-ffmpeg-unpacked: $(GST_FFMPEG_DIR)/.unpacked

gst-ffmpeg-dirclean:
	rm -rf $(GST_FFMPEG_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_GST_FFMPEG),y)
TARGETS+=gst-ffmpeg
endif
