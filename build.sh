#!/bin/sh

case $1 in
	# those two are pretty straight-forward
	arm-devel)
		cp raumfeld/br2-devel-arm.config .config
		make oldconfig
		make
		;;
	geode-devel)
		cp raumfeld/br2-devel-geode.config .config
		make oldconfig
		make
		;;

	default)
		echo "unknown target '$1'. bummer."
		exit -1
esac

