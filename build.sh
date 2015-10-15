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

echo_usage() {
cat << __EOF__ >&2
Usage: $0 --target=<target> [--image=<image> --version=<version> --build=<number>]
       $0 --update-configs

   target is one of
__EOF__

for t in $targets; do echo "		$t"; done

cat << __EOF__ >&2

   image   is optional and can be one of 'init flash final'
   version is optional and can be used to specify the version;
           if unspecified the version is taken from the last git tag
   build   is an optional number which is appened to the version

   If --update-configs is specified, the target configs are all ran
   thru 'make oldconfig'. No further action is taken.

__EOF__
	exit 1
}

. ./getopt.inc
getopt $*

set -e

if [ ! -z "$update_configs" ]; then
	for x in $targets; do
		echo "updating config for $x ..."
		if [ -e .config ]; then
		    mv .config .config.last.active
		else
			rm -f .config.last.active
		fi
		cp raumfeld/br2-$x.config .config
		/usr/bin/make oldconfig
		cp .config raumfeld/br2-$x.config
		if [ -e .config.last.active ]; then
		    mv .config.last.active .config
		fi
	done

	exit 0
fi

test -z "$target" && echo_usage

found=0

for x in $targets; do
	[ "$x" = "$target" ] && found=1
done

if [ "$found" != "1" ]; then
	echo "unknown target '$target'. bummer."
	exit 1
fi


# put the .config file in place

cp raumfeld/br2-$target.config .config
make oldconfig


# cleanup from previous builds

make raumfeld-dirclean
make clean


# update the raumfeld-version

if [ -z "$version" ]; then
  git_version=$(git describe --tags --abbrev=0)
  version=${git_version#raumfeld-}
fi

if [ -n "$build" ]; then
  versionstr="$version.$build"
fi

./buildlog.sh $0: versionstr=$versionstr

mkdir -p raumfeld/rootfs/etc
echo $versionstr > raumfeld/rootfs/etc/raumfeld-version


# run the actual build process

make


# do post-processing for some targets ...

export GENEXT2FS="$(pwd)/output/host/usr/bin/genext2fs"

./build-finish.sh --target=$target --image=$image --version=$versionstr
