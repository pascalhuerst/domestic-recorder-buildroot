#!/bin/sh
#
# post-build.sh for the devel-arm target

echo "Populating the root filesystem ..."
cp -r raumfeld/rootfs-arm/* $1
