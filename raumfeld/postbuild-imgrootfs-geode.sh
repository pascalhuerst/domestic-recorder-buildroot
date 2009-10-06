#!/bin/sh
#
# post-build.sh for the imgrootfs-arm target

echo "Populating the root filesystem ..."

cp -av raumfeld/testsuite/rootfs/* $1/

echo "Building and installing test binaries..."

GCC=build_i586/staging_dir/usr/bin/i586-linux-uclibcgnueabi-gcc

$GCC -o $1/progress_fb -Wall raumfeld/testsuite/progress_fb/progress_fb.c
$GCC -o $1/input_test -Wall raumfeld/testsuite/input_test/input_test.c
$GCC -o $1/percent -Wall raumfeld/testsuite/percent/percent.c

