################################################################################
#
# raumfeld-certificates
#
################################################################################

RAUMFELD_CERTIFICATES_SOURCE =

RAUMFELD_CERTIFICATES_DEPENDENCIES = ca-certificates

RAUMFELD_CERTIFICATES_FILES += bag.software.pem

define RAUMFELD_CERTIFICATES_INSTALL_RAUMFELD_CERTS
	mkdir -p $(TARGET_DIR)/etc/ssl/certs
	$(foreach file,$(RAUMFELD_CERTIFICATES_FILES), \
		$(INSTALL) -m 0644 -D package/raumfeld/raumfeld-certificates/$(file) $(TARGET_DIR)/etc/ssl/certs)
endef

# add the certificates necessary for validating raumfeld to our bundle
# if we ever change our certification authority we need to adapt it
# check chain with i.e.: https://www.sslshopper.com/ssl-checker.html#hostname=api.raumfeld.com
# and compare with the Issuers
define RAUMFELD_CERTIFICATES_CREATE_BUNDLE
	$(foreach file,$(RAUMFELD_CERTIFICATES_FILES), \
		cat package/raumfeld/raumfeld-certificates/$(file) >> $(TARGET_DIR)/etc/ssl/raumfeld-certs.crt)
	cat $(TARGET_DIR)/etc/ssl/certs/COMOD* >> $(TARGET_DIR)/etc/ssl/raumfeld-certs.crt
	cat $(TARGET_DIR)/etc/ssl/certs/AddTrust* >> $(TARGET_DIR)/etc/ssl/raumfeld-certs.crt
endef

define RAUMFELD_CERTIFICATES_INSTALL_TARGET_CMDS
	$(RAUMFELD_CERTIFICATES_INSTALL_RAUMFELD_CERTS)
	$(RAUMFELD_CERTIFICATES_CREATE_BUNDLE)
endef

$(eval $(generic-package))
