#!/bin/sh
#
# post-build.sh for the base-geode target

echo "Populating the root filesystem ..."

rm -f $1/etc/resolv.conf

cp -r raumfeld/rootfs/* $1
cp -r raumfeld/rootfs-geode/* $1

echo "Creating the harddisk mount-point ..."
mkdir -p $1/data

echo "Adding zImage for update ..."
mkdir -p $1/tmp
cp binaries/initramfs-i586/bzImage $1/tmp/raumfeld-update.zImage

raumfeld/postbuild-cleanup.sh $*
