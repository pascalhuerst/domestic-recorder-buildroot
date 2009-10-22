#!/bin/sh

set -e

# initramfs and imgrootfs is needed to build before the other targets,
# so build them first
./build.sh --target=initramfs-arm
./build.sh --target=imgrootfs-arm

./build.sh --target=initramfs-geode
./build.sh --target=imgrootfs-geode

./build.sh --target=audioadapter-arm
./build.sh --target=remotecontrol-arm

./build.sh --target=base-geode
# add others here ...
