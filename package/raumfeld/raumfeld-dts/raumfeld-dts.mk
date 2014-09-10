############################################################
#
# raumfeld-dts
#
#############################################################

RAUMFELD_DTS_VERSION = $(call qstrip,$(BR2_PACKAGE_RAUMFELD_DTS_VERSION))
RAUMFELD_DTS_SITE = $(call qstrip,$(BR2_PACKAGE_RAUMFELD_DTS_REPOSITORY))
RAUMFELD_DTS_SITE_METHOD = git

RAUMFELD_DTS_DEPENDENCIES = linux host-cramfs

define RAUMFELD_DTS_INSTALL_TARGET_CMDS
	@(rm -rf ${BINARIES_DIR}/dts; \
	  mkdir -p ${BINARIES_DIR}/dts; \
	  make LINUX_DIR=${LINUX_DIR} HOSTDIR=${HOST_DIR} DESTDIR=${BINARIES_DIR}/dts/ -C ${RAUMFELD_DTS_DIR})
	@echo "Raumfeld device-tree blobs created in ${BINARIES_DIR}/dts"

	@${HOST_DIR}/usr/bin/mkcramfs ${BINARIES_DIR}/dts ${BINARIES_DIR}/dts.cramfs
	@echo "cramfs image with Raumfeld device-tree blobs created as ${BINARIES_DIR}/dts.cramfs"
endef

$(eval $(generic-package))
