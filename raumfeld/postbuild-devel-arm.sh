#!/bin/sh
#
# post-build.sh for the devel-arm target

echo "Populating the root filesystem ..."
rm -f $1/etc/resolv.conf
cp -r raumfeld/rootfs-arm/* $1
