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


# read the kernel version from the current configuration
KERNEL_VERSION=`grep BR2_LINUX_KERNEL_VERSION .config | cut -f2 -d= | sed -e s/\"//g`


# create a list of all files in the rootfs

if [ -f output/images/rootfs.tar.gz ]; then
    tar ztvf $ROOTFS > $target.contents
else
    (cd output/target ; find . -exec ls -l {} \;) > $target.contents
fi


# copy the output/images directories for later use

mkdir -p binaries/$target
cp -av output/images/* binaries/$target


# do post-processing for some targets ...

case $target in
	initramfs-arm)
        	# copy the ARM zImage for later use in the update image
		cp output/build/linux-$KERNEL_VERSION/arch/arm/boot/zImage binaries/$target
		;;

	imgrootfs-*)
		# resize the root fs ext2 image so that genext2fs will
		# find free inodes when building the deployment targets.
		# this should probably be made part of br2 some day.
		/sbin/resize2fs binaries/$target/rootfs.ext2 64M
		;;

	audioadapter-arm|remotecontrol-arm)
                ROOTFS=output/images/rootfs.tar.gz
                KERNEL=binaries/initramfs-arm/zImage
		for t in $IMAGES; do
			raumfeld/imgcreate.sh \
				--target=$target-$t \
				--platform=arm \
				--base-rootfs-img=binaries/imgrootfs-arm/rootfs.ext2 \
				--target-rootfs-tgz=$ROOTFS \
				--kernel=$KERNEL \
			        --version=$version
		done
		;;

	base-geode)
                ROOTFS=output/images/rootfs.tar.gz
                KERNEL=binaries/initramfs-geode/bzImage
		for t in $IMAGES; do
			raumfeld/imgcreate.sh \
				--target=$target-$t \
				--platform=geode \
				--base-rootfs-img=binaries/imgrootfs-geode/rootfs.ext2 \
				--target-rootfs-tgz=$ROOTFS \
				--kernel=$KERNEL \
				--version=$version
		done
                ;;
esac


if [ -n "$ROOTFS" ]; then
    # create  the update image
    raumfeld/updatecreate.sh \
	--target=$target \
	--targz=$ROOTFS \
        --kexec=$KERNEL
fi
