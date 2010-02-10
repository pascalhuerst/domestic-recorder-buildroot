#!/bin/sh

hw=$(cat /proc/cpuinfo | grep ^Hardware | cut -f 3 -d' ')
rev=$(cat /proc/cpuinfo | grep ^Revision | cut -f 2 -d: | cut -f2 -d' ')

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
test -z "$ethaddr" || fw_setenv ethaddr $ethaddr

