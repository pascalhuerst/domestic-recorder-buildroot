#!/bin/sh

set -e

# take buildroot's dtc and mkcramfs
HOST_DIR=../../output/host/
MKFS=${HOST_DIR}/usr/bin/mkcramfs
DTC=${HOST_DIR}/usr/bin/dtc

TARGETS=am33xx-raumfeld-connector-0.0.dtb

DIR=$(mktemp -d)

for TARGET in ${TARGETS}; do
	${DTC} -o ${DIR}/${TARGET}.dtb -O dtb ${TARGET}.dts
done

${MKFS} ${DIR} dts.cramfs

rm -fr ${DIR}
