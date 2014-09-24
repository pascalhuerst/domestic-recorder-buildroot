#!/bin/sh

#
# Extract rootfs.tgz to the harddisk.
# No attempt is made to clean up or even format the disk. The
# purpose is to recover from a failed update attempt without
# loosing the user settings, favorites, etc.
#

source tests.inc
cd tests

DEV=/dev/hda
TMPROOT=/tmp/root

./leds-blink 1 &
pid=$!

echo "Mounting filesystems ..."

mkdir $TMPROOT
mount -t ext3 -o rw ${DEV}2 $TMPROOT
mount -t ext3 -o rw ${DEV}1 $TMPROOT/boot

echo "Copying files to harddisk. Please wait ..."

zcat /rootfs.tgz | tar -f - -C $TMPROOT -x
sync

echo "Unmounting filesystems ..."

chmod 0755 $TMPROOT
umount $TMPROOT/boot
umount $TMPROOT

kill $pid
./leds-blink 3 &

sleep 5

echo "Rebooting ..."

reboot
