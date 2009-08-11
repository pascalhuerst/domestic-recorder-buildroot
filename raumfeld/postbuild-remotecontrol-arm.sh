#!/bin/sh
#
# post-build.sh for the remotecontrol-arm target

echo "Populating the root filesystem ..."
rm -f $1/etc/resolv.conf
cp -r raumfeld/rootfs-arm/* $1

if [ -d raumfeld/rootfs-remotecontrol-arm ]; then
    cp -r raumfeld/rootfs-remotecontrol-arm/* $1
fi

# fixme
modules=""

raumfeld/raumfeld-install.sh $1 arm $modules
