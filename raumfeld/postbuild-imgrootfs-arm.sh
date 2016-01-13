#!/bin/sh
#
# post-build.sh for the imgrootfs-arm target

echo "postbuild-imgrootfs-arm.sh $1 $2"

echo "Building and installing test binaries..."

GCC=$HOST_DIR/usr/bin/arm-linux-gcc

$GCC -o $1/input_test -Wall raumfeld/testsuite/input_test/input_test.c
$GCC -o $1/progress_fb -Wall raumfeld/testsuite/progress_fb/progress_fb.c
$GCC -o $1/percent -Wall raumfeld/testsuite/percent/percent.c

raumfeld/postbuild-cleanup.sh $*
