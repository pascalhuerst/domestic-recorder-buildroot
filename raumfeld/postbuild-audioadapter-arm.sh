#!/bin/sh
#
# post-build.sh for the audioadapter-arm and audioadapter-armada targets

echo "Populating the root filesystem ..."
cp -r raumfeld/rootfs/* $1
cp -r raumfeld/rootfs-arm/* $1

if [ -d raumfeld/rootfs-audioadapter-arm ]; then
    cp -r raumfeld/rootfs-audioadapter-arm/* $1
fi

cp output/staging/usr/lib/gconv/ISO8859-1.so $1/usr/lib/gconv

echo "Creating the update mount-point ..."
mkdir -p $1/update

raumfeld/postbuild-cleanup.sh $*
