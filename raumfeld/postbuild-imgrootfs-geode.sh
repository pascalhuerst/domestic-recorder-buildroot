#!/bin/sh
#
# post-build.sh for the imgrootfs-geode target

echo "Building and installing test binaries..."

raumfeld/postbuild-cleanup.sh $*
