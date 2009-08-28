#!/bin/sh

set -e

# initramfs and imgrootfs is needed to build before the other targets,
# so build them first
./build.sh initramfs-arm
./build.sh imgrootfs-arm

./build.sh audioadapter-arm
./build.sh remotecontrol-arm
# add others here ...


# this puts together all created updates and copies them to the update server
# raumfeld/consolidate-updates.sh

