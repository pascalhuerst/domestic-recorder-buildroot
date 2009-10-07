#!/bin/bash

set -e

targets="devel-arm devel-geode			\
         initramfs-arm imgrootfs-arm		\
         initramfs-geode imgrootfs-geode	\
         audioadapter-arm remotecontrol-arm	\
         base-geode"

# create a timestamp

./buildlog.sh $0 $*

echo_usage() {
cat << __EOF__ >&2
Usage: $0 --target=<target> [--image=<image> --revision=<revision>]
       $0 --update-configs

   target is one of
__EOF__

for t in $targets; do echo "		$t"; done

cat << __EOF__ >&2

   image      is optional and can be one of 'init flash final'
   revision   is optional and serves as an identifier for this build

   If --update-configs is specified, the target configs are all ran
   thru 'make oldconfig'. Not further action is taken.

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

		--update-configs)
			for x in $targets; do
				echo "updating config for $x ..."
				cp raumfeld/br2-$x.config .config
				/usr/bin/make oldconfig
				cp .config raumfeld/br2-$x.config
			done

			exit 0;
			;;

		*)		echo_usage ;;
	esac
	shift
done

test -z "$target" && echo_usage

found=0

for x in $targets; do
	[ "$x" = "$target" ] && found=1
done

if [ "$found" = "1" ]; then
	echo "unknown target '$target'. bummer."
	exit 1
fi

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

