#############################################################
#
# raumfeld-extract
#
#############################################################

RAUMFELD_EXTRACT_MODULE = raumfeld-extract

RAUMFELD_EXTRACT_VERSION = $(call qstrip,$(BR2_PACKAGE_RAUMFELD_EXTRACT_VERSION))
RAUMFELD_EXTRACT_SITE = $(call qstrip,$(BR2_PACKAGE_RAUMFELD_EXTRACT_REPOSITORY))
RAUMFELD_EXTRACT_SITE_METHOD = git

RAUMFELD_EXTRACT_DEPENDENCIES = libarchive

define inner-raumfeld-cmake-package

ifndef $(2)_MODULE
  $(2)_MODULE = $(1)
endif


# We use CMAKE_SYSTEM_PROCESSOR in libraumfeld/CMakeLists to work out which
# variant of libunwind to link to. Buildroot should probably define this in
# the toolchain file that pkg-cmake.mk generates, it doesn't at the moment.
$(2)_CONF_OPTS += -DCMAKE_SYSTEM_PROCESSOR=$(KERNEL_ARCH)

$(2)_CONF_OPTS += -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS_RELEASE="" -DCMAKE_C_FLAGS_RELEASE=""

$(2)_CONF_OPTS += -DIN_BUILDROOT_CONTEXT=1

# Call the generic cmake package infrastructure to generate the necessary
# make targets
$(call inner-cmake-package,$(1),$(2),$(2),target)

endef # inner-raumfeld-cmake-package

################################################################################
# raumfeld-cmake-package
#   -- the target generator macro for Raumfeld CMake packages
################################################################################

raumfeld-cmake-package = $(call inner-raumfeld-cmake-package,$(call pkgname),$(call UPPERCASE,$(call pkgname)))

$(eval $(raumfeld-cmake-package))
