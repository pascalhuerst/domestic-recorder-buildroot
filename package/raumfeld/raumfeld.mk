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

$(2)_CONF_OPTS += -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS_RELEASE="" -DCMAKE_C_FLAGS_RELEASE=""

$(2)_CONF_OPTS += -DIN_BUILDROOT_CONTEXT=1

RAUMFELD_DIRCLEAN_TARGETS += $(1)-dirclean

# Call the generic autotools package infrastructure to generate the necessary
# make targets
$(call inner-cmake-package,$(1),$(2),$(2),target)

endef # inner-raumfeld-cmake-package


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
