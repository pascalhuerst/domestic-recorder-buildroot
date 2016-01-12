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

define $(2)_BUILD_CMDS
endef

define $(2)_CLEAN_CMDS
endef

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

include package/raumfeld/*/*.mk
