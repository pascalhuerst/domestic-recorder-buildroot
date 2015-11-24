#!/bin/sh
#
# post-build.sh for the base-armada target

echo "Populating the root filesystem ..."
cp -r raumfeld/rootfs/* $1
cp -r raumfeld/rootfs-arm/* $1
cp -r raumfeld/rootfs-base-armada/* $1

cp $STAGING_DIR/usr/lib/gconv/ISO8859-1.so $1/usr/lib/gconv

echo "Creating the update mount-point ..."
mkdir -p $1/update

raumfeld/postbuild-cleanup.sh $*
