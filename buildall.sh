#!/bin/sh

set -e

# imgrootfs is needed to build the other targets, so build that first
./build.sh imgrootfs-arm

./build.sh remotecontrol-arm
# add others here ...

