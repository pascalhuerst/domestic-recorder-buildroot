#############################################################
#
# gst-fluendo-mp3
#
#############################################################
GST_FLUENDO_MP3_VERSION = 0.10.10
GST_FLUENDO_MP3_SOURCE = gst-fluendo-mp3-$(GST_FLUENDO_MP3_VERSION).tar.bz2
GST_FLUENDO_MP3_SITE = http://core.fluendo.com/gstreamer/src/gst-fluendo-mp3
GST_FLUENDO_MP3_LIBTOOL_PATCH = NO

GST_FLUENDO_MP3_DEPENDENCIES = gstreamer liboil


$(eval $(call AUTOTARGETS,package/multimedia,gst-fluendo-mp3))
