#!/bin/sh

#
# Extract rootfs.tgz to the harddisk. No attempt is made to clean up
# or even format the disk. The purpose is to recover from a failed
# update attempt.
#

source tests.inc
cd tests

DEV=/dev/hda
TMPROOT=/tmp/root

./leds-blink 1 &
pid=$!

echo "Mounting filesystems ..."

mkdir $TMPROOT
mount -t ext3 -o rw,sync ${DEV}2 $TMPROOT
mount -t ext3 -o rw,sync ${DEV}1 $TMPROOT/boot

zcat /rootfs.tgz | tar -f - -C $TMPROOT -xv | \
	/percent `cat /rootfs.tgz.numfiles` | \
	dialog_progress "Copying files to harddisk. Please wait." $DIALOGOPTS
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
