################################################################################
#
# alsa_test_tool
#
################################################################################

ALSA_TEST_TOOL_VERSION = 6e62ada582659f6d117ccb59332c028b4e3031d0
ALSA_TEST_TOOL_SITE = git@github.com:pascalhuerst/alsa_test_tool.git
ALSA_TEST_TOOL_SITE_METHOD = git
ALSA_TEST_TOOL_LICENSE = GPLv3+
ALSA_TEST_TOOL_LICENSE_FILES = LICENSE
ALSA_TEST_TOOL_DEPENDENCIES = alsa-lib
ALSA_TEST_TOOL_INSTALL_TARGET = YES
ALSA_TEST_TOOL_TARGET_DIR = $(TARGET_DIR)/usr/sbin
ALSA_TEST_TOOL_SOURCE_DIR = $(ALSA_TEST_TOOL_DIR)
ALSA_TEST_TOOL_CONF_OPTS += -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/sbin

$(eval $(cmake-package))

