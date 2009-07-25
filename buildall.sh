#!/bin/sh

# imgrootfs is needed to build the other targets, so build that first
./build.sh imgrootfs-arm

./build.sh remotecontrol
# add others here ...

