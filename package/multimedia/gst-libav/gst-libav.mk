
#############################################################
#
# gst-libav
#
#############################################################

GST_LIBAV_VERSION = 1.0.4
GST_LIBAV_SOURCE = gst-libav-$(GST_LIBAV_VERSION).tar.xz
GST_LIBAV_SITE = http://gstreamer.freedesktop.org/src/gst-libav
# GST_LIBAV_INSTALL_STAGING = YES

GST_LIBAV_DEPENDENCIES = host-pkgconf gstreamer gst-plugins-base

GST_LIBAV_CONF_OPT = \
	--with-libav-extra-configure="--target-os=linux \
	                               --disable-debug \
				       --disable-ffmpeg \
				       --disable-avconv \
				       --disable-avdevice \
				       --disable-avplay \
				       --disable-avserver \
                                       --enable-pthreads \
                                       --enable-zlib \
                                       --prefix=$(STAGING_DIR)/usr \
                                       --sysroot=$(STAGING_DIR) \
                                       --host-cc=$(TARGET_CC) \
                                       --cc=$(TARGET_CC) \
                                       --arch=$(BR2_ARCH) \
                                       --enable-cross-compile \
                                       --cross-prefix=$(TARGET_CROSS) \
                                       --disable-shared \
                                       --enable-static \
                                       --disable-bsfs \
                                       --disable-decoders \
                                       --disable-demuxers \
                                       --disable-encoders \
                                       --disable-muxers \
                                       --disable-parsers \
                                       --enable-decoder=aac \
                                       --enable-decoder=alac \
                                       --enable-decoder=wmav1 \
                                       --enable-decoder=wmav2 \
                                       --enable-decoder=wmapro "

ifeq ($(BR2_PACKAGE_BZIP2),y)
GST_LIBAV_DEPENDENCIES += bzip2
endif

ifeq ($(BR2_i386),y)
GST_LIBAV_DEPENDENCIES += host-yasm
endif

$(eval $(autotools-package))
