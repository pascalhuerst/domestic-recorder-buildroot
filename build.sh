#!/bin/sh

set -e

case $1 in
	devel-arm)
		;;
	devel-geode)
		;;
	initramfs-arm)
		;;
	imgrootfs-arm)
		;;
	audioadapter-arm)
		;;
	remotecontrol-arm)
		;;

	configs)
		for x in \
			devel-arm devel-geode \
			initramfs-arm imgrootfs-arm \
			audioadapter-arm remotecontrol-arm; do

			cp raumfeld/br2-$x.config .config
			/usr/bin/make oldconfig
			cp .config raumfeld/br2-$x.config
		done

		exit 0;
		;;

	*)
		echo "unknown target '$1'. bummer."
		exit -1
esac

cp raumfeld/br2-$1.config .config

# is that really needed?
rm -fr build_arm project_build_arm toolchain_build_arm

make oldconfig
make


# do post-processing for some targets ...

./build-finish.sh $*
