#!/bin/sh

hw=$(cat /proc/cpuinfo | grep ^Hardware | cut -f 3 -d' ')
rev=$(fw_printenv boardrev | cut -f 2 -d'=')

if [ -z "$rev" ]; then
    echo "Can't determine current board revision, not updating."
    exit 0
fi

# check if an update is needed
# we update the bootloader if it doesn't pad the board revision to 4 digits
if [ $(expr length $rev) -ge 6 ]; then
    echo "Boot-loader seems to be OK, not updating."
    exit 0
fi

case "$hw" in
	Controller)
		img="raumfeld-controller.bin"
		;;
	Connector)
		img="raumfeld-connector.bin"
		;;
	Speaker)
		img="raumfeld-speaker.bin"
		;;
	*)
		echo "Failed to parse machine data. Oops."
		exit 0
esac

if [ ! -f $img ]; then
	echo "$img does not exist. Bummer."
	exit 0
fi

echo "Updating the boot-loader, cross your fingers ..."

# put image to a writable location
cp $img /tmp && img=/tmp/$img

# update the revision, bail out if this fails
/update-boardrev $img $rev || exit -1

# write the bootloader
dd bs=1024 count=640 if=$img of=/dev/mtdblock0

# force the bootloader to do a env reset with its defaults
fw_setenv reset_env 1
