#!/bin/sh
#
# post-build.sh for the base-geode target

echo "Copying kernel to the root filesystem ..."
mkdir -p $1/boot
cp output/images/bzImage $1/boot

echo "Populating the root filesystem ..."

rm -f $1/etc/resolv.conf

cp -r raumfeld/rootfs/* $1
cp -r raumfeld/rootfs-geode/* $1

cp output/staging/usr/lib/gconv/ISO8859-1.so $1/usr/lib/gconv

echo "Creating the harddisk mount-point ..."
mkdir -p $1/data

raumfeld/postbuild-cleanup.sh $*
