#!/bin/sh
#
# post-build.sh for the base-armada target

echo "Populating the root filesystem ..."
cp -r raumfeld/rootfs/* $1
cp -r raumfeld/rootfs-arm/* $1
cp -r raumfeld/rootfs-base-armada/* $1

cp output/staging/usr/lib/gconv/ISO8859-1.so $1/usr/lib/gconv

raumfeld/postbuild-cleanup.sh $*
