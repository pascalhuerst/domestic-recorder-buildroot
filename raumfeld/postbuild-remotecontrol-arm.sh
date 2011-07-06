#!/bin/sh
#
# post-build.sh for the remotecontrol-arm target

echo "Copying kernel to the root filesystem ..."
mkdir -p $1/boot
cp output/images/uImage $1/boot

echo "Populating the root filesystem ..."
cp -r raumfeld/rootfs/* $1
cp -r raumfeld/rootfs-arm/* $1

if [ -d raumfeld/rootfs-remotecontrol-arm ]; then
    cp -r raumfeld/rootfs-remotecontrol-arm/* $1
fi

echo "Creating the update mount-point ..."
mkdir -p $1/update

raumfeld/postbuild-cleanup.sh $*
