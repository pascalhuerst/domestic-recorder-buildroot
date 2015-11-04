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
	--output-file=<filename>
	--base-rootfs-img=<base-rootfs-img>
	--target-rootfs-tgz=<target-rootfs-tgz>
	--kernel=<kernel>
	--dts-dir=<dir>
	--download-dir=<dir>
	[--version=<version>]

__EOF__
	exit 1
}

add_raumfeld_demo() {
    DOWNLOAD_SITE=http://rf-devel.teufel.local/buildroot/dl
    DOWNLOAD_FILE="Raumfeld Demo.mp3"
    test -f "$download_dir/$DOWNLOAD_FILE" || \
        wget -P $download_dir "$DOWNLOAD_SITE/$DOWNLOAD_FILE"
    cp "$download_dir/$DOWNLOAD_FILE" $tmpdir/
}

add_audiotest_wav() {
    DOWNLOAD_PRIMARY_SITE=http://rf-devel.teufel.local/buildroot/dl
    DOWNLOAD_BACKUP_SITE=http://caiaq.de/download/raumfeld
    DOWNLOAD_FILE="audiotest.wav"
    test -f $download_dir/$DOWNLOAD_FILE || \
        for site in $DOWNLOAD_PRIMARY_SITE $DOWNLOAD_BACKUP_SITE; \
        do wget -P $download_dir $site/$DOWNLOAD_FILE && break; done
    cp $download_dir/$DOWNLOAD_FILE $tmpdir/
}

add_rootfs_tgz() {
    # count entries in rootfs.tgz
    tar -zf $target_rootfs_tgz -t | wc -l > $tmpdir/rootfs.tgz.numfiles
    cp $target_rootfs_tgz $tmpdir/rootfs.tgz
}

add_dtb_cramfs() {
    cp $dts_dir/dts.cramfs $tmpdir/
}

add_uboot_images() {
    cp raumfeld/U-Boot/MLO-armada $tmpdir/
    cp raumfeld/U-Boot/u-boot-armada.img $tmpdir/
}

add_mcu_firmware() {
    cp -rv raumfeld/MCU $tmpdir/
}

add_dsp_firmware() {
    cp -rv raumfeld/DSP $tmpdir/
}


./buildlog.sh $*

. ./getopt.inc
getopt $*

if [ -z "$output_file" ]	|| \
   [ -z "$target" ]		|| \
   [ -z "$base_rootfs_img" ]	|| \
   [ -z "$kernel" ]		|| \
   [ -z "$target_rootfs_tgz" ] ||
   [ -z "$download_dir" ];
then echo_usage; fi

if [ -z "$version" ]; then
    version=$(date +%F-%T)
   auto_version=1
else
    auto_version=0
fi

###### BUILD BINARIES #######
echo "building prerequisites ..."
make -C raumfeld/imgtool

###### CHECK PARMS #######

tmpdir=$(mktemp)-$PPID
testdir=raumfeld/testsuite/

imgcreate=raumfeld/imgtool/imgcreate
imginfo=raumfeld/imgtool/imginfo
resize2fs=/sbin/resize2fs

# ext2_img is created in binaries temporarily; will be removed later
ext2_img=$output_file.ext2

target_img=$output_file

if [ -z "$GENEXT2FS" ]; then
    genext2fs="$(which genext2fs)"
else
    genext2fs="$GENEXT2FS"
fi

test -f $kernel		|| echo "ERROR: $kernel not found"
test -f $kernel		|| exit 1

test -f $rootfstgz	|| echo "ERROR: $rootfstgz not found."
test -f $rootfstgz	|| exit 1

# create directory to hold temporary files
mkdir $tmpdir
echo "Operating in $tmpdir"

check_dts_dir() {
    [[ -d "$dts_dir" ]] || (echo "ERROR: Please pass --dts-dir to point to the directory containing dts.cramfs"; exit 1)
}


# decide what image format we need to create
case $target in
    audioadapter-armada-*)
        check_dts_dir
        img_version=1
        dts_image=$dts_dir/dts.cramfs
        ;;
    base-armada-*)
        check_dts_dir
        img_version=1
        dts_image=$dts_dir/dts.cramfs
        ;;
    *)
        img_version=0
        ;;
esac

###### CREATE THE CONTENT #######

cp -a raumfeld/testsuite/rootfs/* $tmpdir/

# add special files according to the image we are creating
case $target in
    audioadapter-arm-flash)
        add_rootfs_tgz
	;;
    audioadapter-arm-repair)
        add_rootfs_tgz
        ;;

    audioadapter-armada-flash)
        add_rootfs_tgz
	add_dtb_cramfs
        add_mcu_firmware
	add_dsp_firmware
        ;;
    audioadapter-armada-final)
        add_rootfs_tgz
	add_dtb_cramfs
        add_audiotest_wav
        add_uboot_images
        add_mcu_firmware
	add_dsp_firmware
        ;;
    audioadapter-armada-repair)
        add_rootfs_tgz
	add_dtb_cramfs
        ;;
    audioadapter-armada-uboot)
        add_uboot_images
        ;;

    base-armada-flash)
        add_rootfs_tgz
	add_dtb_cramfs
        ;;
    base-armada-final)
        add_rootfs_tgz
	add_dtb_cramfs
        add_uboot_images
        ;;
    base-armada-repair)
        add_rootfs_tgz
	add_dtb_cramfs
        ;;
    base-armada-uboot)
        add_uboot_images
        ;;

    base-geode-flash)
        add_rootfs_tgz
        add_raumfeld_demo
        ;;
    base-geode-repair)
        add_rootfs_tgz
        ;;

    remotecontrol-arm-flash)
        add_rootfs_tgz
	;;
esac

# sanity check to not create unbootable images
if [ ! -f $tmpdir/$target.sh ]; then
	echo "Eeeek. $tmpdir/$target.sh does not exist. Wrong '--image' parameter!?"
	exit 1
fi

echo "exec /$target.sh \$*" > $tmpdir/start-test.sh
chmod a+x $tmpdir/start-test.sh

# ensure the root fs ext2 image is large enough that genext2fs will find free
# inodes when building the deployment targets.
# this should probably be made part of br2 some day.
/sbin/resize2fs $base_rootfs_img 64M

rm -f $ext2_img
"$genext2fs" -b 1200 -x $base_rootfs_img -d $tmpdir $ext2_img

# shrink the filesystem to the minimum size
# add 4 blocks to work around a bug in resize2fs which sometimes
# calculates a wrong minimum size
size=$($resize2fs -P $ext2_img | cut -d ' ' -f 7)
size=$(expr $size + 4)
$resize2fs $ext2_img $size

###### CREATE THE IMAGE #######

echo "Creating image ..."
echo "Bootstrap image for target $target" > $tmpdir/desc
date >> $tmpdir/desc
echo "Host $(hostname)" >> $tmpdir/desc

mkdir -p binaries
if [ -n "$dts_image" ]; then
    $imgcreate	--version $img_version		\
		--dts-image $dts_image		\
		--kernel $kernel		\
		--description $tmpdir/desc	\
		--rootfs $ext2_img 		\
		--output $output_file
else
    $imgcreate	--version $img_version		\
		--kernel $kernel		\
		--description $tmpdir/desc	\
		--rootfs $ext2_img 		\
		--output $output_file
fi

####### CLEANUP ########

echo "Purging $tmpdir + $ext2_img"
rm -fr $tmpdir
rm -fr $ext2_img

echo "Image ready:"
$imginfo --version $img_version $output_file
ls -hl $output_file
