#############################################################
#
# loopbacktest
#
#############################################################

LOOPBACKTEST_MODULE = renderer

LOOPBACKTEST_DEPENDENCIES = host-pkgconf alsa-lib libglib2

$(eval $(raumfeld-cross-package))

LOOPBACKTEST_SRCDIR = $(LOOPBACKTEST_DIR)/test
