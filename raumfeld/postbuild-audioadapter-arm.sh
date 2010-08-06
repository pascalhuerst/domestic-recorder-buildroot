#!/bin/sh
#
# post-build.sh for the audioadapter-arm target

echo "Populating the root filesystem ..."
cp -r raumfeld/rootfs/* $1
cp -r raumfeld/rootfs-arm/* $1

if [ -d raumfeld/rootfs-audioadapter-arm ]; then
    cp -r raumfeld/rootfs-audioadapter-arm/* $1
fi

echo "Creating the update mount-point ..."
mkdir -p $1/update

echo "Adding zImage for update ..."
mkdir -p $1/tmp
cp binaries/initramfs-arm/raumfeld-update.zImage $1/tmp

raumfeld/postbuild-cleanup.sh $*
