################################################################################
#
# alsa2fifo
#
################################################################################

ALSA2FIFO_VERSION = 8785c7ad0b0217c9bdface24e3a8f61dab4aba39
ALSA2FIFO_SITE = git@github.com:pascalhuerst/alsa2fifo.git
ALSA2FIFO_SITE_METHOD = git
ALSA2FIFO_LICENSE = GPLv3+
ALSA2FIFO_LICENSE_FILES = LICENSE
ALSA2FIFO_DEPENDENCIES = avahi alsa-lib boost
ALSA2FIFO_INSTALL_TARGET = YES
ALSA2FIFO_TARGET_DIR = $(TARGET_DIR)/usr/sbin
ALSA2FIFO_SOURCE_DIR = $(ALSA2FIFO_DIR)
ALSA2FIFO_CONF_OPTS += -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/sbin

$(eval $(cmake-package))
