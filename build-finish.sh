#!/bin/sh

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

while [ "$1" ]; do
	case $1 in
		--target)       target=$2; shift ;;
		--target=*)     target=${1#--target=} ;;

		--image)	image=$2; shift ;;
		--image=*)      image=${1#--image=} ;;

		--revision)     revision=$2; shift ;;
		--revision=*)   revision=${1#--revision=} ;;

		*)	      echo_usage ;;
	esac
	shift
done

test -z "$target" && echo_usage


case $target in
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
		echo "unknown target '$target'. bummer."
		exit 1
esac

# do post-processing for some targets ...

IMAGES="init flash final"
test ! -z "$image" && IMAGES=$image

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
			raumfeld/imgcreate.sh \
				--target=$target-$t \
				--platform=arm \
				--base-rootfs-img=binaries/uclibc/imgrootfs.arm.ext2 \
				--target-rootfs-tgz=binaries/uclibc/rootfs-audioadapter.arm.tar.gz \
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
				--revision=$revision
		done
esac


# write a stamp file

touch build_arm/stamps/build-$target

