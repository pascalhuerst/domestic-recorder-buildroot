#!/bin/bash

targets="devel-arm devel-geode                  \
         initramfs-arm imgrootfs-arm            \
         initramfs-geode imgrootfs-geode        \
         audioadapter-arm remotecontrol-arm     \
         base-geode"

# create a timestamp

./buildlog.sh $0 $*

echo_usage() {
cat << __EOF__ >&2
Usage: $0 --target=<target> [--image=<image> --version=<version>]
       $0 --update-configs

   target is one of
__EOF__

for t in $targets; do echo "            $t"; done

cat << __EOF__ >&2

   image     is optional and can be one of 'init flash final'
   version   is optional and serves as an identifier for this build

   If --update-configs is specified, the target configs are all ran
   thru 'make oldconfig'. No further action is taken.

__EOF__
        exit 1
}

set -e

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


# decide which images should be created ...

IMAGES="init flash final"

if ! test -z "$image"; then
    found=0

    for x in $IMAGES; do
	[ "$x" = "$image" ] && found=1
    done

    if [ "$found" == "1" ]; then
        IMAGES=$image
    else
	echo "unknown image '$image'. bummer."
	exit 1
    fi
fi


# do post-processing for some targets ...

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
                ROOTFS=binaries/uclibc/rootfs-audioadapter.arm.tar.gz
		for t in $IMAGES; do
			raumfeld/imgcreate.sh \
				--target=$target-$t \
				--platform=arm \
				--base-rootfs-img=binaries/uclibc/imgrootfs.arm.ext2 \
				--target-rootfs-tgz=$ROOTFS \
				--kernel=binaries/initramfs-arm/uImage \
			        --version=$version
		done
		;;

	remotecontrol-arm)
                ROOTFS=binaries/uclibc/rootfs-remotecontrol.arm.tar.gz
		for t in $IMAGES; do
			raumfeld/imgcreate.sh \
				--target=$target-$t \
				--platform=arm \
				--base-rootfs-img=binaries/uclibc/imgrootfs.arm.ext2 \
				--target-rootfs-tgz=$ROOTFS \
				--kernel=binaries/initramfs-arm/uImage \
			        --version=$version
		done
		;;

	base-geode)
                ROOTFS=binaries/uclibc/rootfs-base.i586.tar.gz
		for t in $IMAGES; do
			raumfeld/imgcreate.sh \
				--target=$target-$t \
				--platform=geode \
				--base-rootfs-img=binaries/uclibc/imgrootfs.i586.ext2 \
				--target-rootfs-tgz=$ROOTFS \
				--kernel=binaries/initramfs-geode/bzImage \
				--version=$version
		done
                ;;
esac


if [ -n "$ROOTFS" ]; then
    # create a list of all files in the rootfs
    tar ztvf $ROOTFS > $target.contents

    # create  the update image
    raumfeld/updatecreate.sh \
	--target=$target \
	--targz=$ROOTFS
fi
