#!/bin/sh

FILENAME_MLO=/MLO-armada
FILENAME_UBOOT=/u-boot-armada.img

if [ ! -f $FILENAME_UBOOT ]; then
	echo "$FILENAME_UBOOT does not exist. U-Boot and MLO will not be updated"
	exit 0
fi

if [ ! -f $FILENAME_MLO ]; then
	echo "$FILENAME_MLO does not exist. U-Boot and MLO will not be updated"
	exit 0
fi

flash_erase /dev/mtd0 0 0
nandwrite --pad /dev/mtd0 $FILENAME_MLO

flash_erase /dev/mtd4 0 0
nandwrite --pad /dev/mtd4 $FILENAME_UBOOT

echo "u-boot and MLO written"
