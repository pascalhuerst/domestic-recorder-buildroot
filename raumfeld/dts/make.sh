#!/bin/sh

set -e

TARGETS=am33xx-raumfeld-connector

DIR=$(mktemp -d)
DTC=/usr/bin/dtc

# take buildroot's mkfs.ubifs
HOST_DIR=../../output/host/
MKFS=${HOST_DIR}/usr/bin/mkcramfs


# this is hack
module_version=0
baseboard_version=0

for TARGET in ${TARGETS}; do
	${DTC} -o ${DIR}/${TARGET}-${module_version}-${baseboard_version}.dtb -O dtb ${TARGET}.dts
done

${MKFS} ${DIR} dts.cramfs

rm -fr ${DIR}
