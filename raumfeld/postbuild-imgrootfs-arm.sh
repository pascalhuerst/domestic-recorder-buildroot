#!/bin/sh
#
# post-build.sh for the imgrootfs-arm target

echo "postbuild-imgrootfs-arm.sh $1 $2"

echo "Populating the root filesystem ..."

# raumfeld version
cp -r raumfeld/rootfs/etc/raumfeld-version $1/etc

echo "Building and installing test binaries..."

GCC=output/host/usr/bin/arm-linux-gcc

$GCC -o $1/progress_fb -Wall raumfeld/testsuite/progress_fb/progress_fb.c
$GCC -o $1/input_dump -Wall raumfeld/testsuite/input_dump/input_dump.c
$GCC -o $1/input_test -Wall raumfeld/testsuite/input_test/input_test.c
$GCC -o $1/percent -Wall raumfeld/testsuite/percent/percent.c
$GCC -o $1/wireless_scan -Wall raumfeld/testsuite/wireless_scan/wireless_scan.c

$GCC -o $1/update-boardrev -Wall raumfeld/testsuite/bootloader/update-boardrev.c

raumfeld/postbuild-cleanup.sh $*
