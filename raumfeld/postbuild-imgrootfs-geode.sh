#!/bin/sh
#
# post-build.sh for the imgrootfs-geode target

echo "Populating the root filesystem ..."

# raumfeld version
cp -r raumfeld/rootfs/etc/raumfeld-version $1/etc

echo "Building and installing test binaries..."

raumfeld/postbuild-cleanup.sh $*
