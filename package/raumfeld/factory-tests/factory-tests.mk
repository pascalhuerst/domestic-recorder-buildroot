#############################################################
#
# factory-tests
#
#############################################################

FACTORY_TESTS_DEPENDENCIES = host-pkgconf alsa-lib libraumfelddsp renderer-ng-extract

#FACTORY_TESTS_MODELS = raumfeld-element
#define FACTORY_TESTS_INSTALL_DSP_CONFIG_FILES
#	$(foreach model,$(FACTORY_TESTS_MODELS),$(INSTALL) $(RENDERER_NG_SRCDIR)/dsp-config/$(model).xml $(TARGET_DIR)/raumfeld/factory-tests/dsp-config)
#endef
#FACTORY_TESTS_POST_INSTALL_TARGET_HOOKS += FACTORY_TESTS_INSTALL_DSP_CONFIG_FILES

$(eval $(raumfeld-cross-package))
