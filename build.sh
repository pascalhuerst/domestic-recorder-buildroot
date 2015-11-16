#!/bin/bash
#
# build.sh: Top level Raumfeld build script
#
# This is a thin wrapper about the CMake build system, which in turn handles
# running the various Buildroot builds and the image creation.
#
# You don't need to run this to make a build. You can the CMake build system
# directly, for example:
#
#   ./raumfeld-update-version
#   mkdir build
#   cd build
#   cmake ..
#   make all-armada
#
# This script is kept around for now for compatibility.

set -e

targets="audioadapter-arm                       \
         audioadapter-armada                    \
         remotecontrol-arm                      \
         base-armada                            \
         base-geode                             \
         all-arm                                \
         all-armada                             \
         all-geode"

# For compatibility with existing BuildBot and TeamCity instances.
targets="$targets \
         initramfs-arm initramfs-armada initramfs-geode \
         imgrootfs-arm imgrootfs-armada imgrootfs-geode"

echo_usage() {
cat << __EOF__ >&2
Usage: $0 --target=<target> [--version=<version> --build=<number>]
       $0 --update-configs

   target is one of
__EOF__

for t in $targets; do echo "		$t"; done

cat << __EOF__ >&2

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

# update the raumfeld-version

if [ -z "$version" ]; then
  git_version=$(git describe --tags --abbrev=0)
  version=${git_version#raumfeld-}
fi

if [ -n "$build" ]; then
  versionstr="$version.$build"
fi

mkdir -p raumfeld/rootfs/etc
echo $versionstr > raumfeld/rootfs/etc/raumfeld-version


# Set up for CMake build

if [ -d build ]; then
	make -C build buildroot-$target-clean
else
	mkdir build
fi

cd build

cmake -G 'Unix Makefiles' -DCMAKE_VERBOSE_MAKEFILE=1 -DRAUMFELD_VERSION="$versionstr" ..

# run the actual build process

case $target in
    initramfs-*|imgrootfs-*)
        target=buildroot-$target
        ;;
esac

make $target
