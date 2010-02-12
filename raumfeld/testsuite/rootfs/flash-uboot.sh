#!/bin/sh

hw=$(cat /proc/cpuinfo | grep ^Hardware | cut -f 3 -d' ')
rev=$(cat /proc/cpuinfo | grep ^Revision | cut -f 2 -d: | cut -f2 -d' ')

# ancient version of our hardware do not report the revision.
# default to '1' in this case.

if [ "$rev" == "0000" ]; then
	rev="0001"
fi

case "$hw" in
	Controller)
		img="raumfeld-controller-$rev.bin"
		;;
	Connector)
		img="raumfeld-connector-$rev.bin"
		;;
	Speaker)
		img="raumfeld-speaker-$rev.bin"
		;;
	*)
		echo "Failed to parse machine data. Ups."
		exit 0
esac

if [ ! -f /$img ]; then
	echo "/$img does not exist. Bummer."
	exit 0
fi

# write the bootloader
dd bs=1024 count=640 if=/$img of=/dev/mtdblock0

# reset the environment, save ethaddr if already set
eval $(fw_printenv ethaddr)
dd bs=1024 count=128 skip=640 if=/$img of=/dev/mtdblock1
if [ "$ethaddr" ]; then
	fw_setenv ethaddr $ethaddr
	# force the bootloader to do a env reset with its defaults
	fw_setenv reset_env 1
fi

# write the bootloader splash image
dd bs=1024 count=384 skip=768 if=/$img of=/dev/mtdblock2

