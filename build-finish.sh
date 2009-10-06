#!/bin/sh

# build-finish.sh <target> [revision]
#
#   target     is one of devel-arm, devel-geode,
#                        initramfs-arm, imgrootfs-arm,
#                        audioadapter-arm, remotecontrol-arm
#   revision   is optional and serves as an identifier for this build
#
# build-finish.sh is usually called from build.sh at the end of a
# successful build. The reason it exists as a separate script is so
# that you can fix a broken build, finish it and run build-finish.sh
# manually.

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
	initramfs-geode)
		;;
	imgrootfs-geode)
		;;
	audioadapter-arm)
		;;
	remotecontrol-arm)
		;;
	base-geode)
		;;
	*)
		echo "unknown target '$1'. bummer."
		exit 1
esac

./buildlog.sh $0 $*

# do post-processing for some targets ...

IMAGES="init flash final"
test ! -z "$2" && IMAGES=$2

case $1 in
	# resize the root fs ext2 image so that genext2fs will find
	# free inodes when building the deployment targets.
	# this should probably be made part of br2 some day.
	imgrootfs-arm)
		/sbin/resize2fs binaries/uclibc/imgrootfs.arm.ext2 500M
		;;
	imgrootfs-geode)
		/sbin/resize2fs binaries/uclibc/imgrootfs.i586.ext2 500M
		;;

	audioadapter-arm)
		for t in $IMAGES; do
			raumfeld/imgcreate.sh $1-$t arm \
				binaries/uclibc/imgrootfs.arm.ext2 \
				binaries/uclibc/rootfs-audioadapter.arm.tar.gz
		done

		raumfeld/updatecreate.sh $1 \
			binaries/uclibc/rootfs-audioadapter.arm.tar.gz
		;;
	remotecontrol-arm)
		for t in $IMAGES; do
			raumfeld/imgcreate.sh $1-$t arm \
				binaries/uclibc/imgrootfs.arm.ext2 \
				binaries/uclibc/rootfs-remotecontrol.arm.tar.gz
		done

		raumfeld/updatecreate.sh $1 \
			binaries/uclibc/rootfs-remotecontrol.arm.tar.gz
		;;
	base-geode)
		for t in $IMAGES; do
			raumfeld/imgcreate.sh $1-$t geode \
				binaries/uclibc/imgrootfs.i586.ext2 \
				binaries/uclibc/rootfs-base.geode.tar.gz
		done
esac


# write a stamp file

touch build_arm/stamps/build-$1
