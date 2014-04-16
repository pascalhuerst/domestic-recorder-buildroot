#############################################################
#
# spotify-embedded
#
#############################################################

SPOTIFY_EMBEDDED_VERSION = 1.1.0
SPOTIFY_EMBEDDED_SITE = http://rf-devel.teufel.local/devel/builldroot/dl
SPOTIFY_EMBEDDED_INSTALL_STAGING = YES

ifeq ($(BR2_cortex_a8),y)
  SPOTIFY_EMBEDDED_ARCHITECTURE = TI-Sitara-AM3x
else ifeq ($(BR2_i386),y)
  SPOTIFY_EMBEDDED_ARCHITECTURE = Linux-32bit
endif

SPOTIFY_EMBEDDED_ARCHITECTURE_SOURCE = spotify_embedded-v$(SPOTIFY_EMBEDDED_VERSION)-$(SPOTIFY_EMBEDDED_ARCHITECTURE)-Release

define SPOTIFY_EMBEDDED_EXTRACT_ARCHITECTURE
	(cd $(SPOTIFY_EMBEDDED_SRCDIR) && \
	 gzip -d -c $(SPOTIFY_EMBEDDED_ARCHITECTURE_SOURCE).tar.gz \
                | $(TAR) --strip-components=0 -C $(@D) -xf -)
endef

SPOTIFY_EMBEDDED_POST_EXTRACT_HOOKS += SPOTIFY_EMBEDDED_EXTRACT_ARCHITECTURE

define SPOTIFY_EMBEDDED_INSTALL_STAGING_CMDS
	install -D -m 644 $(@D)/$(SPOTIFY_EMBEDDED_ARCHITECTURE_SOURCE)/include/spotify_embedded.h $(STAGING_DIR)/usr/include
	install -D -m 755 $(@D)/$(SPOTIFY_EMBEDDED_ARCHITECTURE_SOURCE)/lib/libspotify_embedded_shared.so $(STAGING_DIR)/usr/lib
endef

define SPOTIFY_EMBEDDED_INSTALL_TARGET_CMDS
	install -D -m 755 $(@D)/$(SPOTIFY_EMBEDDED_ARCHITECTURE_SOURCE)/lib/libspotify_embedded_shared.so $(TARGET_DIR)/usr/lib
endef

$(eval $(generic-package))
