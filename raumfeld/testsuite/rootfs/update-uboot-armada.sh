#!/bin/sh

FILENAME=/u-boot-armada.img

if [ ! -f $FILENAME ]; then
	echo "$FILENAME does not exist. U-Boot will not be updated"
	exit 0
fi


FILESIZE=$(ls -la $FILENAME | awk '{ print $5}')

nanddump /dev/mtd4 -a  | head -c $FILESIZE > /tmp/$FILENAME

if diff $FILENAME /tmp/$FILENAME >/dev/null; then
    echo "u-boot is up to date"
    exit 0
else
    echo "u-boot will be updated"
fi

flash_erase /dev/mtd4 0 0
nandwrite --pad /dev/mtd4 $FILENAME

echo "u-boot updated"