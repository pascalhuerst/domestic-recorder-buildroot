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

echo "Mounting filesystem ..."

mkdir $TMPROOT
mount -t ubifs -o rw ubi0:RootFS $TMPROOT

echo "Copying files to flash. Please wait ..."

zcat /rootfs.tgz | tar -f - -C $TMPROOT -x
sync

echo "Unmounting filesystem ..."

chmod 0755 $TMPROOT
umount $TMPROOT

kill $pid
./leds-blink 3 &

sleep 5

echo "Rebooting ..."

reboot
