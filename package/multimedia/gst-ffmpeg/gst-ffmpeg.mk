#############################################################
#
# gst-ffmpeg
#
#############################################################

GST_FFMPEG_VERSION = 0.10.11
GST_FFMPEG_SOURCE = gst-ffmpeg-$(GST_FFMPEG_VERSION).tar.bz2
GST_FFMPEG_SITE = http://gstreamer.freedesktop.org/src/gst-ffmpeg
GST_FFMPEG_INSTALL_STAGING = YES
GST_FFMPEG_DEPENDENCIES = gstreamer gst-plugins-base

GST_FFMPEG_CONF_OPT = \
	--with-ffmpeg-extra-configure="--target-os=linux \
				       --disable-ffmpeg \
                                       --disable-ffplay \
                                       --disable-ffserver \
                                       --disable-avfilter \
                                       --disable-swscale \
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
                                       --disable-encoders \
                                       --disable-muxers \
				       --disable-iwmmxt"

ifeq ($(BR2_PACKAGE_BZIP2),y)
GST_FFMPEG_DEPENDENCIES += bzip2
endif

$(eval $(call AUTOTARGETS,package/multimedia,gst-ffmpeg))
