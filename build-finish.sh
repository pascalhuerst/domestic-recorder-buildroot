#!/bin/bash

set -e

targets="initramfs-arm imgrootfs-arm		\
         initramfs-armada imgrootfs-armada      \
         initramfs-geode imgrootfs-geode	\
         audioadapter-arm                       \
         audioadapter-armada                    \
         remotecontrol-arm	                \
         base-armada                            \
         base-geode"


# create a timestamp

./buildlog.sh $0 $*


# check command-line parameters

echo_usage() {
cat << __EOF__ >&2
Usage: $0 --target=<target> [--image=<image> --version=<version>]

   target is one of
__EOF__

for t in $targets; do echo "            $t"; done

cat << __EOF__ >&2

   image     is optional and can be one of 'init flash final repair'
   version   is optional and serves as an identifier for this build

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

case $target in
    *-armada)
        IMAGES="flash final repair"
        ;;
    audioadapter-arm)
        IMAGES="flash repair"
        ;;
    remotecontrol-arm)
        IMAGES="flash"
        ;;
    base-geode)
        IMAGES="flash repair"
        ;;
esac

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


# do post-processing ...


mkdir -p binaries/$target

case $target in
	initramfs-arm*)
        	# copy the ARM kernel images for later use
                cp output/images/uImage binaries/$target
		;;

        initramfs-geode)
                # copy the Geode kernel image for later use
                cp output/images/bzImage binaries/$target
                ;;

	imgrootfs-*)
                cp output/images/rootfs.ext2 binaries/$target
		;;

	audioadapter-arm)
                ROOTFS=output/images/rootfs.tar.gz
                KERNEL=binaries/initramfs-arm/uImage
		for t in $IMAGES; do
			raumfeld/imgcreate.sh \
				--output-file=binaries/${target}-${t}-${version}.img \
				--target=$target-$t \
				--base-rootfs-img=binaries/imgrootfs-arm/rootfs.ext2 \
				--target-rootfs-tgz=$ROOTFS \
				--kernel=$KERNEL \
			        --version=$version
		done
		;;

	remotecontrol-arm)
                ROOTFS=output/images/rootfs.tar.gz
                KERNEL=binaries/initramfs-arm/uImage
		for t in $IMAGES; do
			raumfeld/imgcreate.sh \
				--output-file=binaries/${target}-${t}-${version}.img \
				--target=$target-$t \
				--base-rootfs-img=binaries/imgrootfs-arm/rootfs.ext2 \
				--target-rootfs-tgz=$ROOTFS \
				--kernel=$KERNEL \
			        --version=$version
		done
		;;

	*-armada)
                ROOTFS=output/images/rootfs.tar.gz
                KERNEL=binaries/initramfs-armada/uImage
		PAYLOAD=raumfeld/MCU/RaumfeldSoundbar.bin,raumfeld/MCU/RaumfeldSounddeck.bin,raumfeld/DSP/RaumfeldSoundbarDSP.bin,raumfeld/DSP/RaumfeldSounddeckDSP.bin
		for t in $IMAGES; do
			raumfeld/imgcreate.sh \
				--output-file=binaries/${target}-${t}-${version}.img \
				--target=$target-$t \
				--base-rootfs-img=binaries/imgrootfs-armada/rootfs.ext2 \
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
				--output-file=binaries/${target}-${t}-${version}.img \
				--target=$target-$t \
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
        --kexec=$KERNEL \
        --payload=$PAYLOAD
fi
