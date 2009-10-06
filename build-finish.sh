#!/bin/bash

set -e

./buildlog.sh $0 $*

echo_usage() {
cat << __EOF__ >&2
Usage: $0 --target=<target> [--image=<image> --revision=<revision>]

   target     is one of devel-arm, devel-geode,
                        initramfs-arm, imgrootfs-arm,
                        initramfs-geode, imgroofs-geode,
                        audioadapter-arm, remotecontrol-arm
                        base-geode
   image      is optional and can be one of 'init flash final'
   revision   is optional and serves as an identifier for this build

__EOF__
        exit 1
}

. ./getopt.inc
getopt $*

test -z "$target" && echo_usage

found=0

for x in $targets; do
	[ "$x" = "$target" ] && found=1
done

if [ "$found" != "1" ]; then
	echo "unknown target '$target'. bummer."
	exit 1
fi

# do post-processing for some targets ...

IMAGES="init flash final"
test ! -z "$image" && IMAGES=$image

case $target in
	# resize the root fs ext2 image so that genext2fs will find
	# free inodes when building the deployment targets.
	# this should probably be made part of br2 some day.
	imgrootfs-arm)
		/sbin/resize2fs binaries/uclibc/imgrootfs.arm.ext2 100M
		;;
	imgrootfs-geode)
		/sbin/resize2fs binaries/uclibc/imgrootfs.i586.ext2 100M
		;;

	audioadapter-arm)
		for t in $IMAGES; do
			raumfeld/imgcreate.sh \
				--target=$target-$t \
				--platform=arm \
				--base-rootfs-img=binaries/uclibc/imgrootfs.arm.ext2 \
				--target-rootfs-tgz=binaries/uclibc/rootfs-audioadapter.arm.tar.gz \
				--kernel=binaries/initramfs-arm/uImage \
			        --revision=$revision
		done

		raumfeld/updatecreate.sh \
			--target=$target \
			--targz=binaries/uclibc/rootfs-audioadapter.arm.tar.gz
		;;
	remotecontrol-arm)
		for t in $IMAGES; do
			raumfeld/imgcreate.sh \
				--target=$target-$t \
				--platform=arm \
				--base-rootfs-img=binaries/uclibc/imgrootfs.arm.ext2 \
				--target-rootfs-tgz=binaries/uclibc/rootfs-remotecontrol.arm.tar.gz \
				--kernel=binaries/initramfs-arm/uImage \
			        --revision=$revision
		done

		raumfeld/updatecreate.sh \
			--target=$target \
			--targz=binaries/uclibc/rootfs-remotecontrol.arm.tar.gz
		;;
	base-geode)
		for t in $IMAGES; do
			raumfeld/imgcreate.sh \
				--target=$target-$t \
				--platform=geode \
				--base-rootfs-img=binaries/uclibc/imgrootfs.i586.ext2 \
				--target-rootfs-tgz=binaries/uclibc/rootfs-base.geode.tar.gz \
				--kernel=binaries/initramfs-geode/bzImage \
				--revision=$revision
		done
esac


# write a stamp file
eval `grep BR2_ARCH .config`
touch build_$BR2_ARCH/stamps/build-$target

