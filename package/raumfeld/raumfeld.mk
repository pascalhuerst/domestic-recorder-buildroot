################################################################################
# inner-raumfeld-dummy-package
#
#  argument 1 is the lowercase package name
#  argument 2 is the uppercase package name
################################################################################

define inner-raumfeld-dummy-package

ifndef $(2)_MODULE
  $(2)_MODULE = $(1)
endif

$(2)_OVERRIDE_SRCDIR = $(BUILD_DIR)/raumfeld-repo-$(call qstrip,$(BR2_PACKAGE_RAUMFELD_REPO_VERSION))/$$($(2)_MODULE)

define $(2)_BUILD_CMDS
endef

define $(2)_CLEAN_CMDS
  rm -rf $$($(2)_TARGET_DIR)
  $(MAKE) -C $$($(2)_DIR) CROSS=$$(CROSS) clean
endef

$(2)_DEPENDENCIES += raumfeld-repo

RAUMFELD_DIRCLEAN_TARGETS += $(1)-dirclean

# Call the generic package infrastructure to generate the necessary
# make targets
$(call inner-generic-package,$(1),$(2),$(2),target)

endef # inner-raumfeld-dummy-package


################################################################################
# raumfeld-dummy-package
#   -- the target generator macro for Raumfeld cross-compile packages
################################################################################

raumfeld-dummy-package = $(call inner-raumfeld-dummy-package,$(call pkgname),$(call UPPERCASE,$(call pkgname)))


################################################################################
################################################################################

RAUMFELD_DIRCLEAN_TARGETS = mcu-protocol-dlclean mcu-protocol-dirclean raumfeld-repo-dlclean raumfeld-repo-dirclean

include package/raumfeld/*/*.mk

raumfeld-dirclean: $(RAUMFELD_DIRCLEAN_TARGETS)
