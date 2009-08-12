#!/bin/sh
#
# post-build.sh for the imgrootfs-arm target

echo "Populating the root filesystem ..."

cp -av raumfeld/testsuite/rootfs/* $1/
cp -av raumfeld/rootfs-arm/lib $1


echo "Creating SSH host keys..."

SSH_KEYGEN="ssh-keygen -q -N \"\" -C \"Raumfeld factory tests\"" 

$SSH_KEYGEN -t dsa -f $1/etc/ssh_host_dsa_key
$SSH_KEYGEN -t rsa -f $1/etc/ssh_host_rsa_key


echo "Building and installing test binaries..."

GCC=build_arm/staging_dir/usr/bin/arm-linux-gcc

$GCC -o $1/input_test -Wall raumfeld/testsuite/input_test/input_test.c
$GCC -o $1/percent -Wall raumfeld/testsuite/percent/percent.c
