################################################################################
#
# gst1-libav
#
################################################################################

GST1_LIBAV_VERSION = 1.2.2
GST1_LIBAV_SOURCE = gst-libav-$(GST1_LIBAV_VERSION).tar.xz
GST1_LIBAV_SITE = http://gstreamer.freedesktop.org/src/gst-libav

GST1_LIBAV_DEPENDENCIES = host-pkgconf gstreamer1 gst1-plugins-base

GST1_LIBAV_CONF_OPT = \
	--with-libav-extra-configure="--target-os=linux \
	                               --disable-debug \
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
GST1_LIBAV_DEPENDENCIES += bzip2
endif

ifeq ($(BR2_i386),y)
GST1_LIBAV_DEPENDENCIES += host-yasm
endif

$(eval $(autotools-package))
