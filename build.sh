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
	remotecontrol-arm)
		;;

	configs)
		for x in \
			devel-arm devel-geode \
			initramfs-arm imgrootfs-arm \
			remotecontrol-arm; do

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
#rm -fr build_arm project_build_arm

make oldconfig
make


# do post-processing for some targets ...

case $1 in
	# resize the root fs ext2 image so that genext2fs will find
	# free inodes when building the deployment targets.
	# this should probably be made part of br2 some day.
	imgrootfs-arm)
		/sbin/resize2fs binaries/uclibc/imgrootfs.arm.ext2 500M
		;;
	imgrootfs-geode)
		/sbin/resize2fs binaries/uclibc/imgrootfs.geode.ext2 500M
		;;

	remotecontrol-arm)
		for t in flash init final; do
			raumfeld/imgcreate.sh $1-$t arm \
				binaries/uclibc/imgrootfs.arm.ext2 \
				binaries/uclibc/rootfs-remotecontrol.arm.tar.gz
		done
		;;
esac

