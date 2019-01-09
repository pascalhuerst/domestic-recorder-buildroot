################################################################################
#
# nlimagemaker
#
################################################################################

NLIMAGEMAKER_VERSION = 70da97af6b5a7e3c51e3cbe49093b81212587429
NLIMAGEMAKER_SITE = git@github.com:nonlinear-labs-dev/nlimagemaker.git
NLIMAGEMAKER_SITE_METHOD = git
NLIMAGEMAKER_LICENSE = GPLv3+
NLIMAGEMAKER_LICENSE_FILES = COPYING
NLIMAGEMAKER_DEPENDENCIES =
NLIMAGEMAKER_INSTALL_TARGET = YES
NLIMAGEMAKER_TARGET_DIR = $(TARGET_DIR)/usr/sbin
NLIMAGEMAKER_SOURCE_DIR = $(NLIMAGEMAKER_DIR)
NLIMAGEMAKER_CONF_OPTS += -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/sbin

$(eval $(cmake-package))
$(eval $(host-cmake-package))

