#!/bin/sh

set -e

# create a timestamp

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
		--target)	target=$2; shift ;;
		--target=*)	target=${1#--target=} ;;

		--image)	image=$2; shift ;;
		--image=*)	image=${1#--image=} ;;

		--revision)	revision=$2; shift ;;
		--revision=*)	revision=${1#--revision=} ;;

		*)		echo_usage ;;
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

	configs)
		for x in \
			devel-arm devel-geode base-geode \
			initramfs-arm imgrootfs-arm \
			initramfs-geode imgrootfs-geode \
			audioadapter-arm remotecontrol-arm; do

                        echo "updating config for $x ..."
			cp raumfeld/br2-$x.config .config
			/usr/bin/make oldconfig
			cp .config raumfeld/br2-$x.config
		done

		exit 0;
		;;

	*)
		echo "unknown target '$target'. bummer."
		exit 1
esac


# cleanup from previous builds

eval `grep BR2_ARCH .config`
rm -fr build_$BR2_ARCH project_build_$BR2_ARCH toolchain_build_$BR2_ARCH


# put the .config file in place

cp raumfeld/br2-$target.config .config
make oldconfig


# run the actual build process

make

# do post-processing for some targets ...

./build-finish.sh --target=$target --image=$image --revision=$revision

