RAUMFELD_REPO_VERSION = $(call qstrip,$(BR2_PACKAGE_RAUMFELD_REPO_VERSION))
RAUMFELD_REPO_SITE = $(call qstrip,$(BR2_PACKAGE_RAUMFELD_REPO_LOCATION))
RAUMFELD_REPO_SITE_METHOD = git

$(eval $(generic-package))

raumfeld-repo-dlclean:
	rm -f $(DL_DIR)/$(RAUMFELD_REPO_SOURCE)
