#!/bin/sh
#
# post-build.sh for the imgrootfs-arm target

echo "Populating the root filesystem ..."

cp -av raumfeld/testsuite/rootfs/* $1/


echo "Creating SSH host keys..."

ssh-keygen -q -t dsa -N "" -C "Raumfeld factory tests" -f $1/etc/ssh_host_dsa
ssh-keygen -q -t rsa -N "" -C "Raumfeld factory tests" -f $1/etc/ssh_host_rsa


echo "Building and installing test binaries..."

GCC=build_arm/staging_dir/usr/bin/arm-linux-gcc

$GCC -o $1/input_test -Wall raumfeld/testsuite/input_test/input_test.c
$GCC -o $1/percent -Wall raumfeld/testsuite/percent/percent.c
