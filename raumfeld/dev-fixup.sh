#!/bin/bash

if ! [ -n "$1" ]; then
    echo "Please specify the rootfs location."
    exit 1
fi

ROOTFS=$1
if ! [ -d $ROOTFS ]; then
    echo "Please compile buildroot before running this script."
    exit 1
fi


if ! [ -n "$2" ]; then
    echo "Please specify the target platform."
    exit 1
fi

PLATFORM=$2
case $PLATFORM in
    arm)
        DEVICE_GROUPS="generic-arm input usb"
        SOUND_DEVICES="y"
        ;;

    geode)
        DEVICE_GROUPS="generic-i386 input usb"
        ;;
    *)
        echo "unknown platform"
        exit 1;
esac


sudo rm -rf $ROOTFS/dev

# Create the device files

echo "Creating devices ..."
sudo mkdir $ROOTFS/dev

for GROUP in $DEVICE_GROUPS; do
   (cd $ROOTFS/dev; sudo /sbin/MAKEDEV $GROUP)
done

# /dev/pts
(cd $ROOTFS/dev;
    sudo mkdir pts;
    for n in {0..4}; do
        sudo mknod --mode=620 pts/$n c 136 $n
        sudo chgrp tty pts/$n
    done)

# /dev/snd
if [ ! -z "$SOUND_DEVICES" ]; then
    (cd $ROOTFS/dev;
        sudo mkdir snd;
        sudo mknod --mode=666 snd/controlC0 c 116 0;
        sudo mknod --mode=666 snd/seq       c 116 1;
        for n in {0..7}; do
            CMINOR=$(( $n + 24 ))
            PMINOR=$(( $n + 16 ))
            sudo mknod --mode=666 snd/pcmC0D${n}c c 116 $CMINOR
            sudo mknod --mode=666 snd/pcmC0D${n}p c 116 $PMINOR
        done;
        sudo mknod --mode=666 snd/timer     c 116 33;
        sudo chgrp audio snd/*)
fi
