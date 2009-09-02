#!/bin/sh
#
# post-build.sh for the remotecontrol-arm target

echo "Populating the root filesystem ..."
cp -r raumfeld/rootfs-arm/* $1

if [ -d raumfeld/rootfs-remotecontrol-arm ]; then
    cp -r raumfeld/rootfs-remotecontrol-arm/* $1
fi

