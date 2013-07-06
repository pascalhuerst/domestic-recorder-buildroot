################################################################################
# inner-raumfeld-cross-package
#
#  argument 1 is the lowercase package name
#  argument 2 is the uppercase package name
#  argument 3 is the package directory prefix
################################################################################

define inner-raumfeld-cross-package

ifndef $(2)_MODULE
  $(2)_MODULE = $(1)
endif

$(2)_OVERRIDE_SRCDIR = $(BUILD_DIR)/raumfeld-repo-$(call qstrip,$(BR2_PACKAGE_RAUMFELD_REPO_VERSION))/$$($(2)_MODULE)

ifeq ($(ARCH),arm)
  CROSS = ARM
  EXTRA_MAKE_OPTS = ARM_TYPE=$(call qstrip,$(BR2_UCLIBC_ARM_TYPE))
endif
ifeq ($(ARCH),i586)
  CROSS = GEODE
endif

define $(2)_BUILD_CMDS
  $(MAKE) -C $$($(2)_SRCDIR) CROSS=$$(CROSS) $$(EXTRA_MAKE_OPTS) DEST=$(TARGET_DIR)/raumfeld CROSS_PREFIX=$(BASE_DIR)
endef

define $(2)_CLEAN_CMDS
  rm -rf $$($(2)_TARGET_DIR)
  $(MAKE) -C $$($(2)_DIR) CROSS=$$(CROSS) clean
endef

RAUMFELD_DIRCLEAN_TARGETS += $(1)-dirclean

# Call the generic package infrastructure to generate the necessary
# make targets
$(call inner-generic-package,$(1),$(2),$(2),$(3),target)

# The rsync target depends on raumfeld-repo to be extracted
$$($(2)_TARGET_RSYNC): raumfeld-repo-extract

endef # inner-raumfeld-cross-package


################################################################################
# inner-raumfeld-autotools-package
#
#  argument 1 is the lowercase package name
#  argument 2 is the uppercase package name
#  argument 3 is the package directory prefix
################################################################################

define inner-raumfeld-autotools-package

ifndef $(2)_MODULE
  $(2)_MODULE = $(1)
endif

$(2)_OVERRIDE_SRCDIR = $(BUILD_DIR)/raumfeld-repo-$(call qstrip,$(BR2_PACKAGE_RAUMFELD_REPO_VERSION))/$$($(2)_MODULE)

ifndef $(2)_AUTORECONF
  $(2)_AUTORECONF = YES
endif

define $(2)_AUTORECONF_M4_HOOK
  $(Q) mkdir $$($(2)_SRCDIR)/m4
endef

define $(2)_GTKDOCIZE_HOOK
  $(Q) cd $$($(2)_SRCDIR) && gtkdocize
endef

$(2)_PRE_CONFIGURE_HOOKS = $(2)_AUTORECONF_M4_HOOK

ifeq ($$($(2)_GTKDOCIZE),YES)
$(2)_PRE_CONFIGURE_HOOKS += $(2)_GTKDOCIZE_HOOK
endif

RAUMFELD_DIRCLEAN_TARGETS += $(1)-dirclean

# Call the generic autotools package infrastructure to generate the necessary
# make targets
$(call inner-autotools-package,$(1),$(2),$(2),$(3),target)

# The rsync target depends on raumfeld-repo to be extracted
$$($(2)_TARGET_RSYNC): raumfeld-repo-extract

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

RAUMFELD_DIRCLEAN_TARGETS = raumfeld-repo-dlclean raumfeld-repo-dirclean

include package/raumfeld/*/*.mk

raumfeld-dirclean: $(RAUMFELD_DIRCLEAN_TARGETS)
