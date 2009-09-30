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

                        echo "updating config for $x ..."
			cp raumfeld/br2-$x.config .config
			/usr/bin/make oldconfig
			cp .config raumfeld/br2-$x.config
		done

		exit 0;
		;;

	*)
		echo "unknown target '$1'. bummer."
		exit 1
esac


# cleanup from previous builds

eval `grep BR2_ARCH .config`
rm -fr build_$BR2_ARCH project_build_$BR2_ARCH

# uncomment the following line if you also want to rebuild the toolchain
# rm -fr toolchain_build_$BR2_ARCH


# create a timestamp

./buildlog.sh $0 $*


# put the .config file in place

cp raumfeld/br2-$1.config .config
make oldconfig


# run the actual build process

make


# do post-processing for some targets ...

./build-finish.sh $*
