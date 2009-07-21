#!/bin/sh
#
# post-build.sh for the devel-arm target

raumfeld/dev-fixup.sh $1 arm

echo "Populating the root filesystem ..."
rm -f $1/etc/resolv.conf
cp -r raumfeld/rootfs-arm/* $1

echo "Changing ownership of the root filesystem to root.root ..."
sudo chown -R root.root $1
