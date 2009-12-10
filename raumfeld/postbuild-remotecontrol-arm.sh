#!/bin/sh
#
# post-build.sh for the remotecontrol-arm target

echo "Populating the root filesystem ..."
cp -r raumfeld/rootfs/* $1
cp -r raumfeld/rootfs-arm/* $1

if [ -d raumfeld/rootfs-remotecontrol-arm ]; then
    cp -r raumfeld/rootfs-remotecontrol-arm/* $1
fi

echo "Creating the update mount-point ..."
mkdir $1/update

raumfeld/postbuild-cleanup.sh $1
