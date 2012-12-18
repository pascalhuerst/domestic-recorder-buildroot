################################################################################
# raumfeld-bzr-source
#
#  argument 1 is the lowercase package name
#  argument 2 is the uppercase package name
################################################################################

define raumfeld-bzr-source

	@$(call MESSAGE,"Checking out $(1) from $$($(2)_BRANCH)")
	if ! test -d $$($(2)_DIR)/.bzr; then \
		(cd $$(BUILD_DIR); \
		$$(call qstrip,$$(BR2_BZR)) checkout -q --lightweight $$($(2)_SITE) $$($(2)_DIR)) \
	else \
		(cd $$($(2)_DIR); $$(call qstrip,$$(BR2_BZR)) update -q) \
	fi

endef


################################################################################
# inner-raumfeld-cross-package
#
#  argument 1 is the lowercase package name
#  argument 2 is the uppercase package name
#  argument 3 is the package directory prefix
################################################################################

define inner-raumfeld-cross-package


ifndef $(2)_BRANCH
  $(2)_BRANCH = $(call qstrip,$(BR2_PACKAGE_RAUMFELD_BRANCH))
endif

ifndef $(2)_MODULE
  $(2)_MODULE = $(1)
endif


ifndef $(2)_SOURCE_DIR
  $(2)_SOURCE_DIR = $$($(2)_DIR)
endif

ifndef $(2)_TARGET_DIR
  $(2)_TARGET_DIR = $(TARGET_DIR)/raumfeld/$(1)
endif


ifeq ($(ARCH),arm)
  CROSS = ARM
  EXTRA_MAKE_OPTS = ARM_TYPE=$(call qstrip,$(BR2_UCLIBC_ARM_TYPE))
endif
ifeq ($(ARCH),i586)
  CROSS = GEODE
endif


define $(2)_BUILD_CMDS
  $(MAKE) -C $$($(2)_SOURCE_DIR) CROSS=$$(CROSS) $$(EXTRA_MAKE_OPTS) DEST=$(TARGET_DIR)/raumfeld CROSS_PREFIX=$(BASE_DIR)
endef

define $(2)_CLEAN_CMDS
  rm -rf $$($(2)_TARGET_DIR)
  $(MAKE) -C $$($(2)_DIR) CROSS=$$(CROSS) clean
endef


ifeq ($$($(2)_BRANCH),trunk)
$(2)_SITE = $$(call qstrip,$$(BR2_PACKAGE_RAUMFELD_REPOSITORY))/$$($(2)_MODULE)/trunk
else
$(2)_SITE = $$(call qstrip,$$(BR2_PACKAGE_RAUMFELD_REPOSITORY))/$$($(2)_MODULE)/branches/$$($(2)_BRANCH)
endif

ifndef $(2)_SITE_METHOD
  $(2)_SITE_METHOD = override
endif


RAUMFELD_DIRCLEAN_TARGETS += $(1)-dirclean


# Call the generic package infrastructure to generate the necessary
# make targets
$(call inner-generic-package,$(1),$(2),$(2),$(3),target)


# Override download and extract targets

$$($(2)_DIR)/.stamp_downloaded:
	$(call raumfeld-bzr-source,$(1),$(2))
	$(Q)touch $$@

$(2)_EXTRACT_CMDS = $$($(2)_POST_EXTRACT_HOOKS)


endef # inner-raumfeld-cross-package


################################################################################
# inner-raumfeld-autotools-package
#
#  argument 1 is the lowercase package name
#  argument 2 is the uppercase package name
#  argument 3 is the package directory prefix
################################################################################

define inner-raumfeld-autotools-package


ifndef $(2)_BRANCH
  $(2)_BRANCH = $(call qstrip,$(BR2_PACKAGE_RAUMFELD_BRANCH))
endif

ifndef $(2)_MODULE
  $(2)_MODULE = $(1)
endif

ifndef $(2)_AUTORECONF
  $(2)_AUTORECONF = YES
endif


ifeq ($$($(2)_BRANCH),trunk)
$(2)_SITE = $$(call qstrip,$$(BR2_PACKAGE_RAUMFELD_REPOSITORY))/$$($(2)_MODULE)/trunk
else
$(2)_SITE = $$(call qstrip,$$(BR2_PACKAGE_RAUMFELD_REPOSITORY))/$$($(2)_MODULE)/branches/$$($(2)_BRANCH)
endif

ifndef $(2)_SITE_METHOD
  $(2)_SITE_METHOD = override
endif


RAUMFELD_DIRCLEAN_TARGETS += $(1)-dirclean


# Call the generic autotools package infrastructure to generate the necessary
# make targets
$(call inner-autotools-package,$(1),$(2),$(2),$(3),target)


# Override download and extract targets

$$($(2)_DIR)/.stamp_downloaded:
	$(call raumfeld-bzr-source,$(1),$(2))
	$(Q)touch $$@

$(2)_EXTRACT_CMDS = $$($(2)_POST_EXTRACT_HOOKS)


endef # inner-raumfeld-autotools-package


################################################################################
# raumfeld-autotools-package
#   -- the target generator macro for Raumfeld autotools packages
################################################################################

raumfeld-autotools-package = $(call inner-raumfeld-autotools-package,$(call pkgname),$(call UPPERCASE,$(call pkgname)),$(call pkgparentdir))


################################################################################
# raumfeld-cross-package
#   -- the target generator macro for Raumfeld cross-compile packages
################################################################################

raumfeld-cross-package = $(call inner-raumfeld-cross-package,$(call pkgname),$(call UPPERCASE,$(call pkgname)),$(call pkgparentdir))


################################################################################
################################################################################

RAUMFELD_DIRCLEAN_TARGETS =

include package/raumfeld/*/*.mk

raumfeld-rebuild: $(RAUMFELD_DIRCLEAN_TARGETS) all
