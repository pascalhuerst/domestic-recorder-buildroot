#!/bin/bash

#
# This is what the user of this script has to provide:
#
# - a kernel image that contains a initramfs which mounts the ext2
#   part of the resulting image and executes /init.sh ($kernel)
# - the imgcreate utility and a path to it ($imgcreate)
# - a minimal file system that contains everything you want
#   the system to run upon start ($rootfsdir)
# - the testsuite which is copied together with the rootfs (testdir)
#
# Optionally this script takes a version identifier as extra
# parameter. If this is unspecified a version is created from
# the current date and time.

set -e

echo_usage() {
cat << __EOF__ >&2
Usage: $0 --target=<target>
	--platform=<platform>
	--base-rootfs-img=<base-rootfs-img>
	--target-rootfs-tgz=<target-rootfs-tgz>
	--kernel=<kernel>
	[--version=<version>]

__EOF__
	exit 1
}

add_raumfeld_demo() {
    DOWNLOAD_SITE=http://rf-devel.teufel.local/buildroot/dl
    DOWNLOAD_FILE="Raumfeld Demo.mp3"
    test -f "dl/$DOWNLOAD_FILE" || \
        wget -P dl "$DOWNLOAD_SITE/$DOWNLOAD_FILE"
    cp "dl/$DOWNLOAD_FILE" $tmpdir/
}

add_audiotest_wav() {
    DOWNLOAD_PRIMARY_SITE=http://rf-devel.teufel.local/buildroot/dl
    DOWNLOAD_BACKUP_SITE=http://caiaq.de/download/raumfeld
    DOWNLOAD_FILE="audiotest.wav"
    test -f dl/$DOWNLOAD_FILE || \
        for site in $DOWNLOAD_PRIMARY_SITE $DOWNLOAD_BACKUP_SITE; \
        do wget -P dl $site/$DOWNLOAD_FILE && break; done
    cp dl/$DOWNLOAD_FILE $tmpdir/
}

add_rootfs_tgz() {
    # count entries in rootfs.tgz
    tar -zf $target_rootfs_tgz -t | wc -l > $tmpdir/rootfs.tgz.numfiles
    cp $target_rootfs_tgz $tmpdir/rootfs.tgz
}

./buildlog.sh $*

. ./getopt.inc
getopt $*

if [ -z "$target" ]		|| \
   [ -z "$platform" ]		|| \
   [ -z "$base_rootfs_img" ]	|| \
   [ -z "$kernel" ]		|| \
   [ -z "$target_rootfs_tgz" ];
then echo_usage; fi

test -z "$version" && version=$(date +%F-%T)

###### BUILD BINARIES #######
echo "building prerequisites ..."
make -C raumfeld/imgtool

###### CHECK PARMS #######

tmpdir=$(tempfile)-$PPID
testdir=raumfeld/testsuite/
imgcreate=raumfeld/imgtool/imgcreate
imginfo=raumfeld/imgtool/imginfo
resize2fs=/sbin/resize2fs

# ext2_img is created in binaries temporarily; will be removed later
ext2_img=binaries/$target.ext2

target_img=binaries/$target-$version.img
img_version=0
build_dts=0
dts_image=

test -f $kernel		|| echo "ERROR: $kernel not found"
test -f $kernel		|| exit 1

test -f $rootfstgz	|| echo "ERROR: $rootfstgz not found."
test -f $rootfstgz	|| exit 1

###### CREATE THE CONTENT #######

mkdir $tmpdir
echo "Operating in $tmpdir"

cp -a raumfeld/testsuite/rootfs/* $tmpdir/

# add special files according to the image we are creating
case $target in
    audioadapter-arm-init)
        add_rootfs_tgz
        add_audiotest_wav
        ;;
    audioadapter-arm-flash)
        add_rootfs_tgz
	cp raumfeld/U-Boot/raumfeld-connector.bin $tmpdir/
	cp raumfeld/U-Boot/raumfeld-speaker.bin $tmpdir/
	;;
    audioadapter-arm-final)
        add_audiotest_wav
        ;;
    audioadapter-arm-uboot)
	cp raumfeld/U-Boot/raumfeld-connector.bin $tmpdir/
	cp raumfeld/U-Boot/raumfeld-speaker.bin $tmpdir/
	;;

    audioadapter-armada-init)
        add_rootfs_tgz
	img_version=1
	build_dts=1
        ;;
    audioadapter-armada-flash)
        add_rootfs_tgz
	img_version=1
	build_dts=1
        ;;

    base-geode-init)
        add_rootfs_tgz
        add_raumfeld_demo
        ;;
    base-geode-flash)
        add_rootfs_tgz
        add_raumfeld_demo
	cp raumfeld/Coreboot/raumfeld-base.rom $tmpdir/
        ;;
    base-geode-final)
        add_rootfs_tgz
        ;;
    base-geode-coreboot)
	cp raumfeld/Coreboot/raumfeld-base.rom $tmpdir/
	cp -a raumfeld/testsuite/coreboot $tmpdir/
	;;

    remotecontrol-arm-init)
        add_rootfs_tgz
	;;
    remotecontrol-arm-flash)
        add_rootfs_tgz
	cp raumfeld/U-Boot/raumfeld-controller.bin $tmpdir/
	;;
    remotecontrol-arm-uboot)
	cp raumfeld/U-Boot/raumfeld-controller.bin $tmpdir/
	;;
esac

# sanity check to not create unbootable images
if [ ! -f $tmpdir/$target.sh ]; then
	echo "Eeeek. $tmpdir/$target.sh does not exist. Wrong '--image' parameter!?"
	exit 1
fi

echo "exec /$target.sh \$*" > $tmpdir/start-test.sh
chmod a+x $tmpdir/start-test.sh

rm -f $ext2_img
genext2fs -b 1024 -x $base_rootfs_img -d $tmpdir $ext2_img

# shrink the filesystem to the minimum size
# add 4 blocks to work around a bug in resize2fs which sometimes
# calculates a wrong minimum size
size=$($resize2fs -P $ext2_img | cut -d ' ' -f 7)
size=$(expr $size + 4)
$resize2fs $ext2_img $size

###### CRATE DTS IMAGE #######

if [ "$build_dts" -eq 1 ]; then
	pushd .
	cd raumfeld/dts/
	./make.sh
	popd

	dts_image=dts/dts.cramfs
fi

###### CREATE THE IMAGE #######

echo "Creating image ..."
echo "Bootstrap image for target $target" > $tmpdir/desc
date >> $tmpdir/desc
echo "Host $(hostname)" >> $tmpdir/desc

mkdir -p binaries
$imgcreate	--version $img_version		\
		--dts-image $dts_image		\
		--kernel $kernel		\
		--description $tmpdir/desc	\
		--rootfs $ext2_img 		\
		--output $target_img

####### CLEANUP ########

echo "Purging $tmpdir + $ext2_img"
rm -fr $tmpdir
rm -fr $ext2_img

echo "Image ready:"
$imginfo $target_img
ls -hl $target_img

