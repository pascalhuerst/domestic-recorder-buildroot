#!/bin/sh
#
# post-build.sh for the audioadapter-arm target

echo "Populating the root filesystem ..."
cp -r raumfeld/rootfs-arm/* $1

if [ -d raumfeld/rootfs-audioadapter-arm ]; then
    cp -r raumfeld/rootfs-audioadapter-arm/* $1
fi

raumfeld/postbuild-cleanup.sh $1

