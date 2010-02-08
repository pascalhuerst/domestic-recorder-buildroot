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
		if [ -z "`cat /proc/cpuinfo | grep ^revision | grep \ 010`" ]
			img="raumfeld-speaker_s.bin"
		else
			img="raumfeld-speaker_m.bin"
		fi
		;;
	*)
		exit 0
esac

cat /$img > /dev/mtdblock0

