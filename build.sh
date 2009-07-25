#!/bin/sh

set -e

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
	remotecontrol-arm)
		cp raumfeld/br2-remotecontrol-arm.config .config
		;;

	default)
		echo "unknown target '$1'. bummer."
		exit -1
esac

# is that really needed?
rm -fr build_arm

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
				binaries/uclibc/rootfs-remotecontrol.arm.ext2
		done
		;;
esac

