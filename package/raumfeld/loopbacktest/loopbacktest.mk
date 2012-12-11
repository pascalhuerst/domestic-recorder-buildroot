#############################################################
#
# loopbacktest
#
#############################################################

LOOPBACKTEST_MODULE = p0-renderer
LOOPBACKTEST_SOURCE_DIR = $(LOOPBACKTEST_DIR)/test
LOOPBACKTEST_TARGET_DIR = $(TARGET_DIR)/raumfeld/p0-audiotest

LOOPBACKTEST_DEPENDENCIES = host-pkgconf host-orc alsa-lib orc libglib2

$(eval $(raumfeld-cross-package))
