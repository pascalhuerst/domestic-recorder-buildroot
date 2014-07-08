#!/bin/sh

FILENAME_UBOOT=/u-boot-armada.img
NANDSIZE_UBOOT=1048576

FILENAME_MLO=/MLO-armada
NANDSIZE_MLO=131072

if [ ! -f $FILENAME_UBOOT ]; then
	echo "$FILENAME_UBOOT does not exist. U-Boot and MLO will not be updated"
	exit 0
fi

if [ ! -f $FILENAME_MLO ]; then
	echo "$FILENAME_MLO does not exist. U-Boot and MLO will not be updated"
	exit 0
fi

MD5=$(nanddump /dev/mtd4 -a | md5sum | cut -f1 -d" ")

VERSION=0
LATEST=5

case $MD5 in
	8424f0114c15ede1108bf8d2cea863fb)
		# br2 git: 8694b87
		# 2011.09-00424-gfd8bba0 (Jun 12 2013 - 13:45:27)
		VERSION=1
		;;
	f83661180940803f3515a8fb9161f9e9)
		# br2 git: 3bdc334
		# 2011.09-00426-g7880e1b-dirty (Feb 21 2014 - 12:59:08)
		VERSION=2
		;;
	991d63bc3505e1837fb19b25a859cd08)
		# br2 git: 192cfbc
		# 2011.09-00428-gd581a32 (Apr 08 2014 - 17:02:01)
		VERSION=3
		;;
	a0aae2ac85b175a4c3e8ef3c36066d2e)
		# br2 git: e02f9ac
		# 2011.09-00435-gbde5ebc-dirty (May 08 2014 - 11:37:04)
		VERSION=4
		;;
	64619d5562cc36a4bf7623cf68526079)
		# br2 git: 906dc6d
		# U-Boot 2014.07-rc4-00097-ge95e4e4-dirty (Jul 08 2014 - 11:55:37)
		VERSION=5
		;;
	*)
		echo "UNKNOWN BOOTLOADER! NOT UPDATING!"
		echo "Please report the following md5sum: $MD5"
		exit 0
		;;
esac

echo "Detected U-Boot VERSION is $VERSION (md5 $MD5)"

if [ $VERSION -lt $LATEST ]; then
    echo "u-boot will be updated"
else
    echo "u-boot is up to date"
    exit 0
fi

flash_erase /dev/mtd0 0 0
nandwrite --pad /dev/mtd0 $FILENAME_MLO

flash_erase /dev/mtd4 0 0
nandwrite --pad /dev/mtd4 $FILENAME_UBOOT

echo "u-boot and MLO updated"
