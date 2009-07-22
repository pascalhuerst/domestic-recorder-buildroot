#!/bin/sh
#
# post-build.sh for the devel-arm target

echo "Populating the root filesystem ..."

cp -av raumfeld/testsuite/rootfs/* $1/

# FIXME: cross-compile and copy input_test


