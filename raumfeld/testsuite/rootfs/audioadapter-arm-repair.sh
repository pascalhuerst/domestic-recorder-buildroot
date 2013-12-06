#!/bin/sh

#
# Extract rootfs.tgz to the flash.
# No attempt is made to clean up or even format the flash. The
# purpose is to recover from a failed update attempt without
# loosing the user settings, favorites, etc.
#

source tests.inc
cd tests

TMPROOT=/tmp/root

./leds-blink 1 &
pid=$!

echo "Mounting filesystems ..."

mkdir $TMPROOT
mount -t ubifs -o rw ubi0:RootFS $TMPROOT

zcat /rootfs.tgz | tar -f - -C $TMPROOT -xv | \
	/percent `cat /rootfs.tgz.numfiles` | \
	dialog_progress "Copying files to flash. Please wait." $DIALOGOPTS
sync

echo "Unmounting filesystems ..."

chmod 0755 $TMPROOT
umount $TMPROOT

kill $pid
./leds-blink 3 &

sleep 5

echo "Rebooting ..."

reboot
