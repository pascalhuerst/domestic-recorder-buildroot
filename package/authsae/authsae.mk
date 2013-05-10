#############################################################
#
# authsae
#
#############################################################

AUTHSAE_VERSION = d825a6eff3351cda27e167d61597efce1b6db03d
AUTHSAE_SITE = git://github.com/cozybit/authsae.git
AUTHSAE_INSTALL_STAGING = YES
AUTHSAE_DEPENDENCIES = libnl libconfig openssl

$(eval $(cmake-package))
