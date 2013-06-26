#!/bin/sh

FILENAME=/u-boot-armada.img

if [ ! -f $FILENAME ]; then
	echo "$FILENAME does not exist. U-Boot will not be updated"
	exit 0
fi

flash_erase /dev/mtd4 0 0
nandwrite --pad /dev/mtd4 $FILENAME

echo "u-boot updated"