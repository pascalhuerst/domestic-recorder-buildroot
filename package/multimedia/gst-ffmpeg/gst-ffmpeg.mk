
#############################################################
#
# gst-ffmpeg
#
#############################################################

GST_FFMPEG_VERSION = 0.11.2
GST_FFMPEG_SOURCE = gst-ffmpeg-$(GST_FFMPEG_VERSION).tar.bz2
GST_FFMPEG_SITE = http://gstreamer.freedesktop.org/src/gst-ffmpeg
GST_FFMPEG_INSTALL_STAGING = YES

GST_FFMPEG_DEPENDENCIES = host-pkgconf gstreamer gst-plugins-base

GST_FFMPEG_CONF_OPT = \
	--with-ffmpeg-extra-configure="--target-os=linux \
	                               --disable-debug \
				       --disable-ffmpeg \
                                       --disable-ffplay \
                                       --disable-ffserver \
                                       --disable-avfilter \
                                       --enable-gpl \
                                       --enable-pthreads \
                                       --enable-zlib \
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
				       --disable-iwmmxt \
                                       --disable-bsfs \
                                       --disable-decoders \
                                       --disable-demuxers \
                                       --disable-encoders \
                                       --disable-filters \
                                       --disable-muxers \
                                       --disable-parsers \
                                       --disable-protocols \
                                       --enable-decoder=aac \
                                       --enable-decoder=alac \
                                       --enable-decoder=wmav1 \
                                       --enable-decoder=wmav2 \
                                       --enable-decoder=wmapro "

ifeq ($(BR2_PACKAGE_BZIP2),y)
GST_FFMPEG_DEPENDENCIES += bzip2
endif

$(eval $(autotools-package))
