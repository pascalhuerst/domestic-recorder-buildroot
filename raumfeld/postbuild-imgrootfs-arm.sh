#!/bin/sh
#
# post-build.sh for the devel-arm target

echo "Populating the root filesystem ..."

cp -av raumfeld/testsuite/rootfs/* $1/

GCC=build_arm/staging_dir/usr/bin/arm-linux-gcc

$GCC -o $1/input_test -Wall raumfeld/testsuite/input_test/input_test.c
$GCC -o $1/percent -Wall raumfeld/testsuite/percent/percent.c

