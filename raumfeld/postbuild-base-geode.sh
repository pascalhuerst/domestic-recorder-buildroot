#!/bin/sh
#
# post-build.sh for the base-geode target

echo "Populating the root filesystem ..."

rm -f $1/etc/resolv.conf

cp -r raumfeld/rootfs/* $1
cp -r raumfeld/rootfs-geode/* $1

mkdir -p $1/data

raumfeld/postbuild-cleanup.sh $1
