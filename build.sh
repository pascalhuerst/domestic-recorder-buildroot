#!/bin/sh

case $1 in
	# those two are pretty straight-forward
	devel-arm)
		cp raumfeld/br2-devel-arm.config .config
		;;
	devel-geode)
		cp raumfeld/br2-devel-geode.config .config
		;;
	imgrootfs-arm)
		cp raumfeld/br2-imgrootfs-arm.config .config
		;;

	default)
		echo "unknown target '$1'. bummer."
		exit -1
esac

make oldconfig
make

