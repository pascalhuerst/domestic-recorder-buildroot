#!/bin/sh

hw=`cat /proc/cpuinfo | grep ^Hardware | cut -f 3 -d' '`

if [ -z "$hw" ]; then
	hw=`cat /proc/cpuinfo | grep ^model\ name | cut -f 3 -d' '`
fi

case "$hw" in
	Controller)
		img="raumfeld-controller.bin"
		;;
	Connector)
		img="raumfeld-connector.bin"
		;;
	Speaker)
		if [ -z "`cat /proc/cpuinfo | grep ^revision | grep \ 010`" ]; then
			img="raumfeld-speaker_s.bin"
		else
			img="raumfeld-speaker_m.bin"
		fi
		;;
	*)
		exit 0
esac

# write the bootloader
dd bs=1024 count=640 if=/$img of=/dev/mtdblock0

# reset the environment, save ethaddr if already set
eval $(fw_printenv ethaddr)
dd bs=1024 count=128 skip=640 if=/$img of=/dev/mtdblock1
test -z "$ethaddr" || fw_setenv ethaddr $ethaddr

