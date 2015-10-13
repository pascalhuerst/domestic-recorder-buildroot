################################################################################
# inner-raumfeld-cross-package
#
#  argument 1 is the lowercase package name
#  argument 2 is the uppercase package name
################################################################################

define inner-raumfeld-cross-package

ifndef $(2)_MODULE
  $(2)_MODULE = $(1)
endif

$(2)_OVERRIDE_SRCDIR = $(BUILD_DIR)/raumfeld-repo-$(call qstrip,$(BR2_PACKAGE_RAUMFELD_REPO_VERSION))/$$($(2)_MODULE)

ifeq ($(ARCH),arm)
  CROSS = ARM
endif
ifeq ($(ARCH),i586)
  CROSS = GEODE
endif

ifeq ($(BR2_cortex_a8),y)
  EXTRA_MAKE_OPTS = ARM_TYPE=ARM_CORTEXA8
endif

define $(2)_BUILD_CMDS
  $(MAKE) -C $$($(2)_SRCDIR) TARGET_CFLAGS="$(TARGET_CFLAGS)" CROSS=$$(CROSS) $$(EXTRA_MAKE_OPTS) DEST=$(TARGET_DIR)/raumfeld CROSS_PREFIX=$(BASE_DIR)
endef

define $(2)_CLEAN_CMDS
  rm -rf $$($(2)_TARGET_DIR)
  $(MAKE) -C $$($(2)_DIR) CROSS=$$(CROSS) clean
endef

RAUMFELD_DIRCLEAN_TARGETS += $(1)-dirclean

# The rsync target depends on raumfeld-repo to be extracted
$(2)_DEPENDENCIES += raumfeld-repo

# Call the generic package infrastructure to generate the necessary
# make targets
$(call inner-generic-package,$(1),$(2),$(2),target)

endef # inner-raumfeld-cross-package


################################################################################
# inner-raumfeld-autotools-package
#
#  argument 1 is the lowercase package name
#  argument 2 is the uppercase package name
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
  $(Q) mkdir -p $$($(2)_SRCDIR)/m4
endef

define $(2)_INTLTOOLIZE_HOOK
  $(Q) (cd $$($(2)_SRCDIR) && $(HOST_DIR)/usr/bin/intltoolize)
endef

define $(2)_GTKDOCIZE_HOOK
  $(Q) (cd $$($(2)_SRCDIR) && gtkdocize)
endef

$(2)_PRE_CONFIGURE_HOOKS = $(2)_AUTORECONF_M4_HOOK

ifeq ($$($(2)_INTLTOOLIZE),YES)
$(2)_PRE_CONFIGURE_HOOKS += $(2)_INTLTOOLIZE_HOOK
endif

ifeq ($$($(2)_GTKDOCIZE),YES)
$(2)_PRE_CONFIGURE_HOOKS += $(2)_GTKDOCIZE_HOOK
endif

# The rsync target depends on raumfeld-repo to be extracted
$(2)_DEPENDENCIES += raumfeld-repo

RAUMFELD_DIRCLEAN_TARGETS += $(1)-dirclean

# Call the generic autotools package infrastructure to generate the necessary
# make targets
$(call inner-autotools-package,$(1),$(2),$(2),target)

endef # inner-raumfeld-autotools-package


################################################################################
# inner-raumfeld-cmake-package
#
#  argument 1 is the lowercase package name
#  argument 2 is the uppercase package name
################################################################################

# This is a rather inelegant way to make the custom CMake modules from core.git
# available during the build. Ideally those modules should all be submitted to
# the relevant upstream projects so we can avoid doing this at all.
RAUMFELD_CMAKE_MODULES_DIR = $(BUILD_DIR)/raumfeld-repo-$(call qstrip,$(BR2_PACKAGE_RAUMFELD_REPO_VERSION))/cmake/Modules
define RAUMFELD_CUSTOM_CMAKE_MODULES_HOOK
	cp $(RAUMFELD_CMAKE_MODULES_DIR)/*.cmake $(HOST_DIR)/usr/share/cmake-3.3/Modules
endef

define inner-raumfeld-cmake-package

ifndef $(2)_MODULE
  $(2)_MODULE = $(1)
endif

# The source code for this moduleis fetched from the raumfeld-repo build
# directory, via the OVERRIDE_SRCDIR feature of Buildroot. The raumfeld-repo
# package exists simply to fetch core.git.
$(2)_OVERRIDE_SRCDIR = $(BUILD_DIR)/raumfeld-repo-$(call qstrip,$(BR2_PACKAGE_RAUMFELD_REPO_VERSION))/$$($(2)_MODULE)
$(2)_DEPENDENCIES += raumfeld-repo

$(2)_PRE_CONFIGURE_HOOKS += RAUMFELD_CUSTOM_CMAKE_MODULES_HOOK

# We use CMAKE_SYSTEM_PROCESSOR in libraumfeld/CMakeLists to work out which
# variant of libunwind to link to. Buildroot should probably define this in
# the toolchain file that pkg-cmake.mk generates, it doesn't at the moment.
$(2)_CONF_OPTS += -DCMAKE_SYSTEM_PROCESSOR=$(KERNEL_ARCH)

RAUMFELD_DIRCLEAN_TARGETS += $(1)-dirclean

# Call the generic autotools package infrastructure to generate the necessary
# make targets
$(call inner-cmake-package,$(1),$(2),$(2),target)

endef # inner-raumfeld-cmake-package


################################################################################
# raumfeld-autotools-package
#   -- the target generator macro for Raumfeld autotools packages
################################################################################

raumfeld-autotools-package = $(call inner-raumfeld-autotools-package,$(call pkgname),$(call UPPERCASE,$(call pkgname)))

################################################################################
# raumfeld-cross-package
#   -- the target generator macro for Raumfeld cross-compile packages
################################################################################

raumfeld-cross-package = $(call inner-raumfeld-cross-package,$(call pkgname),$(call UPPERCASE,$(call pkgname)))

################################################################################
# raumfeld-cmake-package
#   -- the target generator macro for Raumfeld CMake packages
################################################################################

raumfeld-cmake-package = $(call inner-raumfeld-cmake-package,$(call pkgname),$(call UPPERCASE,$(call pkgname)))


################################################################################
################################################################################

RAUMFELD_DIRCLEAN_TARGETS = mcu-protocol-dlclean mcu-protocol-dirclean raumfeld-repo-dlclean raumfeld-repo-dirclean

include package/raumfeld/*/*.mk

raumfeld-dirclean: $(RAUMFELD_DIRCLEAN_TARGETS)
