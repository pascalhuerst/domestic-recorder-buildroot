#!/bin/sh

#
# Extract rootfs.tgz, the kernel and the DTB cramfs to the flash.
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

# copy the DTB cramfs image to its own partition
flash_erase /dev/mtd7 0 0
nandwrite --pad /dev/mtd7 /dts.cramfs

# 'move' the uImage from the rootfs to its own partition
flash_erase /dev/mtd6 0 0
nandwrite --pad /dev/mtd6 $TMPROOT/boot/uImage
rm $TMPROOT/boot/uImage

echo "Unmounting filesystem ..."

chmod 0755 $TMPROOT
umount $TMPROOT

kill $pid
./leds-blink 3 &

sleep 5

echo "Rebooting ..."

reboot
