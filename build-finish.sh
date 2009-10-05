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
	*)
		echo "unknown target '$1'. bummer."
		exit 1
esac

./buildlog.sh $0 $*

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

	audioadapter-arm)
		for t in flash init final; do
			raumfeld/imgcreate.sh $1-$t arm \
				binaries/uclibc/imgrootfs.arm.ext2 \
				binaries/uclibc/rootfs-audioadapter.arm.tar.gz
		done

		raumfeld/updatecreate.sh $1 \
			binaries/uclibc/rootfs-audioadapter.arm.tar.gz
		;;
	remotecontrol-arm)
		for t in flash init final; do
			raumfeld/imgcreate.sh $1-$t arm \
				binaries/uclibc/imgrootfs.arm.ext2 \
				binaries/uclibc/rootfs-remotecontrol.arm.tar.gz
		done

		raumfeld/updatecreate.sh $1 \
			binaries/uclibc/rootfs-remotecontrol.arm.tar.gz
		;;
esac


# write a stamp file

touch build_arm/stamps/build-$i
