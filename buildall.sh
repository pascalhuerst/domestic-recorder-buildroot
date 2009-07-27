#!/bin/sh

set -e

# initramfs and imgrootfs is needed to build the other targets, so build that first
./build.sh initramfs-arm
./build.sh imgrootfs-arm

./build.sh remotecontrol-arm
# add others here ...

