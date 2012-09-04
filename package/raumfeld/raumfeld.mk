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


# Call the generic autotools package infrastructure to generate the necessary
# make targets
$(call inner-autotools-package,$(1),$(2),$(2),$(3),target)


# Override download and extract targets

$$($(2)_DIR)/.stamp_downloaded:
	if ! test -d $$($(2)_DIR)/.bzr; then \
		if test $$($(2)_BRANCH) = trunk; then \
			(cd $$(BUILD_DIR); \
			 $$(call qstrip,$$(BR2_BZR)) co -q --lightweight $$(call qstrip,$$(BR2_PACKAGE_RAUMFELD_REPOSITORY))/$$($(2)_MODULE)/trunk $$($(2)_DIR)) \
		else \
			(cd $$(BUILD_DIR); \
			 $$(call qstrip,$$(BR2_BZR)) co -q --lightweight $$(call qstrip,$$(BR2_PACKAGE_RAUMFELD_REPOSITORY))/$$($(2)_MODULE)/branches/$$($(2)_BRANCH) $$($(2)_DIR)) \
		fi \
	fi
	$(Q)touch $$@

$(2)_EXTRACT_CMDS = $$($(2)_POST_EXTRACT_HOOKS)

endef # inner-raumfeld-autotools-package


################################################################################
# raumfeld-autotools-package
#   -- the target generator macro for Raumfeld autotools packages
################################################################################

raumfeld-autotools-package = $(call inner-raumfeld-autotools-package,$(call pkgname),$(call UPPERCASE,$(call pkgname)),$(call pkgparentdir))


################################################################################
################################################################################

include package/raumfeld/*/*.mk
