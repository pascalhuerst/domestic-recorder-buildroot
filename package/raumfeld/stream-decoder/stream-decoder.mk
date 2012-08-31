#############################################################
#
# stream-decoder
#
#############################################################

STREAM_DECODER_VERSION = $(call qstrip,$(BR2_PACKAGE_RAUMFELD_BRANCH))
STREAM_DECODER_AUTORECONF = YES
STREAM_DECODER_LIBTOOL_PATCH = NO
STREAM_DECODER_INSTALL_STAGING = YES
STREAM_DECODER_INSTALL_TARGET = YES

STREAM_DECODER_CONF_OPT = --disable-glibtest

STREAM_DECODER_DEPENDENCIES = host-pkg-config libsoup gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-ffmpeg

$(eval $(call AUTOTARGETS))

$(STREAM_DECODER_DIR)/.bzr:
	if ! test -d $(STREAM_DECODER_DIR)/.bzr; then \
	  	(cd $(BUILD_DIR); \
	 	$(call qstrip,$(BR2_BZR)) co -q --lightweight $(BR2_PACKAGE_RAUMFELD_REPOSITORY)/stream-decoder/$(STREAM_DECODER_VERSION) stream-decoder-$(STREAM_DECODER_VERSION)) \
	fi

$(STREAM_DECODER_DIR)/.stamp_downloaded: $(STREAM_DECODER_DIR)/.bzr
	touch $@

$(STREAM_DECODER_DIR)/.stamp_extracted: $(STREAM_DECODER_DIR)/.stamp_downloaded
	touch $@
