#!/bin/sh
#
# post-build.sh for the imgrootfs-arm target

echo "Populating the root filesystem ..."

# raumfeld version
cp -r raumfeld/rootfs/etc/raumfeld-version $1/etc

# wi2wi firmware
cp -av raumfeld/rootfs-arm/lib $1

echo "Building and installing test binaries..."

GCC=build_arm/staging_dir/usr/bin/arm-linux-gcc

$GCC -o $1/progress_fb -Wall raumfeld/testsuite/progress_fb/progress_fb.c
$GCC -o $1/input_test -Wall raumfeld/testsuite/input_test/input_test.c
$GCC -o $1/percent -Wall raumfeld/testsuite/percent/percent.c

