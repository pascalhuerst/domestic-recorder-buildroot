#############################################################
#
# spotify-embedded
#
#############################################################

SPOTIFY_EMBEDDED_VERSION = 1.12.0
SPOTIFY_EMBEDDED_SITE = http://rf-devel.teufel.local/devel/builldroot/dl
SPOTIFY_EMBEDDED_INSTALL_STAGING = YES

ifeq ($(BR2_xscale),y)
  SPOTIFY_EMBEDDED_RELEASE = spotify_embedded-v$(SPOTIFY_EMBEDDED_VERSION)-Raumfeld-PXA300-Release
else ifeq ($(BR2_cortex_a8),y)
  SPOTIFY_EMBEDDED_RELEASE = spotify_embedded-v$(SPOTIFY_EMBEDDED_VERSION)-Raumfeld-AM33x-Release
endif

SPOTIFY_EMBEDDED_SOURCE = $(SPOTIFY_EMBEDDED_RELEASE).tar.gz
SPOTIFY_EMBEDDED_SUBDIR = spotify_embedded/$(SPOTIFY_EMBEDDED_RELEASE)

define SPOTIFY_EMBEDDED_INSTALL_STAGING_CMDS
	install -D -m 644 $(@D)/$(SPOTIFY_EMBEDDED_SUBDIR)/include/spotify_embedded.h $(STAGING_DIR)/usr/include
	install -D -m 755 $(@D)/$(SPOTIFY_EMBEDDED_SUBDIR)/lib/libspotify_embedded_shared.so $(STAGING_DIR)/usr/lib
endef

define SPOTIFY_EMBEDDED_INSTALL_TARGET_CMDS
	install -D -m 755 $(@D)/$(SPOTIFY_EMBEDDED_SUBDIR)/lib/libspotify_embedded_shared.so $(TARGET_DIR)/usr/lib
endef

$(eval $(generic-package))
