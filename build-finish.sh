#!/bin/bash

targets="initramfs-arm imgrootfs-arm            \
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
	imgrootfs-*)
		# resize the root fs ext2 image so that genext2fs will
		# find free inodes when building the deployment targets.
		# this should probably be made part of br2 some day.
		/sbin/resize2fs output/images/rootfs.ext2 64M
		;;

	audioadapter-arm|remotecontrol-arm)
                ROOTFS=output/images/rootfs.tar.gz
                KERNEL=output/images/uImage
		for t in $IMAGES; do
			raumfeld/imgcreate.sh \
				--target=$target-$t \
				--platform=arm \
				--base-rootfs-img=output/images/rootfs.ext2 \
				--target-rootfs-tgz=$ROOTFS \
				--kernel=$KERNEL \
			        --version=$version
		done
		;;

	base-geode)
                ROOTFS=output/images/rootfs.tar.gz
                KERNEL=output/images/bzImage
		for t in $IMAGES; do
			raumfeld/imgcreate.sh \
				--target=$target-$t \
				--platform=geode \
				--base-rootfs-img=output/images/rootfs.ext2 \
				--target-rootfs-tgz=$ROOTFS \
				--kernel=$KERNEL \
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
	--targz=$ROOTFS \
        --kexec=$KERNEL
fi
