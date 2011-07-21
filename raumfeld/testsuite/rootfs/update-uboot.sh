#!/bin/sh

hw=$(cat /proc/cpuinfo | grep ^Hardware | cut -f 3 -d' ')
rev=$(fw_printenv boardrev | cut -f 2 -d '=')

# ancient version of our hardware do not report the revision.
# default to '1' in this case.

if [ -z "$rev" ]; then
	rev="0x1"
fi

# check if an update is needed
# we update the bootloader if it doesn't pad the board revision to 4 digits
if [ $(expr length $rev) -ge 6 ]; then
    exit 0
fi

case "$hw" in
	Controller)
		img="/raumfeld-controller.bin"
		;;
	Connector)
		img="/raumfeld-connector.bin"
		;;
	Speaker)
		img="/raumfeld-speaker.bin"
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

# update the revision
cp /$img /tmp && img=/tmp/$img
./update-boardrev $img $rev

# write the bootloader
dd bs=1024 count=640 if=$img of=/dev/mtdblock0

# reset the environment, save ethaddr if already set
eval $(fw_printenv ethaddr)
dd bs=1024 count=128 skip=640 if=$img of=/dev/mtdblock1
if [ "$ethaddr" ]; then
	fw_setenv ethaddr $ethaddr
	# force the bootloader to do a env reset with its defaults
	fw_setenv reset_env 1
fi

# write the bootloader splash image
dd bs=1024 count=384 skip=768 if=$img of=/dev/mtdblock2
