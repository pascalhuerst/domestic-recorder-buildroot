#############################################################
#
# spotify-embedded
#
#############################################################

SPOTIFY_EMBEDDED_VERSION = 1.20.10
SPOTIFY_EMBEDDED_SITE = http://rf-devel.teufel.local/devel/buildroot/dl
SPOTIFY_EMBEDDED_INSTALL_STAGING = YES

ifeq ($(BR2_xscale),y)
  SPOTIFY_EMBEDDED_RELEASE = spotify_embedded-v$(SPOTIFY_EMBEDDED_VERSION)-Raumfeld-PXA300-Release
  SPOTIFY_EMBEDDED_LIB = spotify_embedded-vorbis-v$(SPOTIFY_EMBEDDED_VERSION)-Raumfeld-PXA300-Release
else ifeq ($(BR2_cortex_a8),y)
  SPOTIFY_EMBEDDED_RELEASE = spotify_embedded-v$(SPOTIFY_EMBEDDED_VERSION)-Raumfeld-AM33x-Release
  SPOTIFY_EMBEDDED_LIB = spotify_embedded-vorbis-v$(SPOTIFY_EMBEDDED_VERSION)-Raumfeld-AM33x-Release
else
  SPOTIFY_EMBEDDED_RELEASE = spotify_embedded-v$(SPOTIFY_EMBEDDED_VERSION)-Linux-32bit-Release
  SPOTIFY_EMBEDDED_LIB = spotify_embedded-vorbis-v$(SPOTIFY_EMBEDDED_VERSION)-Linux-32bit-Release
endif

SPOTIFY_EMBEDDED_SOURCE = $(SPOTIFY_EMBEDDED_LIB).tar.gz
SPOTIFY_EMBEDDED_SUBDIR = spotify_embedded/$(SPOTIFY_EMBEDDED_RELEASE)

define SPOTIFY_EMBEDDED_INSTALL_STAGING_CMDS
	install -D -m 644 $(@D)/$(SPOTIFY_EMBEDDED_SUBDIR)/include/spotify_embedded.h $(STAGING_DIR)/usr/include
	install -D -m 644 $(@D)/$(SPOTIFY_EMBEDDED_SUBDIR)/include/spotify_embedded_compress.h $(STAGING_DIR)/usr/include
	install -D -m 755 $(@D)/$(SPOTIFY_EMBEDDED_SUBDIR)/lib/libspotify_embedded_shared.so $(STAGING_DIR)/usr/lib
endef

define SPOTIFY_EMBEDDED_INSTALL_TARGET_CMDS
	install -D -m 755 $(@D)/$(SPOTIFY_EMBEDDED_SUBDIR)/lib/libspotify_embedded_shared.so $(TARGET_DIR)/usr/lib
endef

$(eval $(generic-package))
