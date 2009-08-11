#!/bin/sh
#
# post-build.sh for the devel-arm target

echo "Populating the root filesystem ..."
cp -r raumfeld/rootfs-arm/* $1

if [ -d raumfeld/rootfs-devel-arm ]; then
    cp -r raumfeld/rootfs-devel-arm/* $1
fi
