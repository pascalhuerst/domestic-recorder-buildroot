############################################################
#
# uboot-signed
#
#############################################################

UBOOT_SIGNED_VERSION = $(call qstrip,$(BR2_PACKAGE_RAUMFELD_CST_VERSION))
UBOOT_SIGNED_SITE = $(call qstrip,$(BR2_PACKAGE_RAUMFELD_CST_REPOSITORY))
UBOOT_SIGNED_SITE_METHOD = git

UBOOT_SIGNED_DEPENDENCIES = uboot

define UBOOT_SIGNED_INSTALL_TARGET_CMDS
        @cp ${BINARIES_DIR}/u-boot.* ${UBOOT_SIGNED_DIR}/linux64/.
        @(cd ${UBOOT_SIGNED_DIR}/linux64/; \
           ./cst --o u-boot_csf.bin --i u-boot.csf; \
           objcopy -I binary -O binary --pad-to 0x4000 --gap-fill=0x00 u-boot_csf.bin u-boot_csf_pad.bin)
        @cat ${UBOOT_SIGNED_DIR}/linux64/u-boot.imx ${UBOOT_SIGNED_DIR}/linux64/u-boot_csf_pad.bin > ${BINARIES_DIR}/u-boot-signed.imx
        @echo "Signed u-boot binary created as ${BINARIES_DIR}/u-boot-signed.imx"
endef

$(eval $(generic-package))
