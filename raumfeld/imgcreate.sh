#!/bin/sh

#
# This is what the user of this script has to provide:
#
# - an uImage that contains a iniramfs which mounts the ext2
#   part of the resulting image and executes /init.sh ($uimage)
# - the imgcreate utility and a path to it ($imgcreate)
# - a minimal file system that contains everything you want
#   the system to run upon start ($rootfsdir)
# - the testsuite which is copied together with the rootfs (testdir)
#

if test -z "$3"; then
	echo "Usage: $0 <target> <platform> <base-rootfs-tgz> <target-rootfs-tgz>"
	echo "target can be one of the following:"
	echo "	remote-flash"
	echo "	remote-init"
	echo "	remote-final"
	echo "	audioadapter-flash"
	echo "	audioadapter-init"
	echo "	audioadapter-final"
	exit
fi

echo "building prerequisites ..."

make -C raumfeld/imgtool

target=$1
platform=$2
base_rootfs_img=$3
target_rootfs_tgz=$4

tmpdir=$(tempfile)-$PPID
uimage=binaries/uImage-initramfs
testdir=raumfeld/testsuite/
#inputtest_bin=$testdir/input_test/input_test
imgcreate=raumfeld/imgtool/imgcreate
imginfo=raumfeld/imgtool/imginfo
resize2fs=/sbin/resize2fs
# ext2_img has to be created in binaries/ temporarily. will be removed later.
ext2_img=binaries/$target.ext2
target_img=binaries/$target-$(date +%F-%T).img

test -f $uimage		|| (echo "$uimage not found."; exit -1)
test -f $rootfstgz	|| (echo "$rootfstgz not found."; exit -1)
#test -f $inputtest_bin	|| (echo "$inputtest_bin not found."; exit -1)


###### CREATE THE CONTENT #######

mkdir $tmpdir
echo "Operating in $tmpdir"

cp $target_rootfs_tgz $tmpdir/
cp -av raumfeld/testsuite/rootfs/* $tmpdir/

# ext2_img has to be created in binaries/ temporarily. will be removed later.
echo "exec /$target.sh" > $tmpdir/start-test.sh

# count entries in rootfs.tar
tar -f $target_rootfs_tgz -t | wc -l > $tmpdir/$(basename $target_rootfs_tgz).numfiles

rm -f $ext2_img
genext2fs -b 1024 -x $base_rootfs_img -d $tmpdir $ext2_img

# shrink the fs to the max
$resize2fs -M $ext2_img

###### CREATE THE IMAGE #######

echo "Creating image ..."
echo "Bootstrap image for target $target" > $tmpdir/desc
date >> $tmpdir/desc
echo "Host $(hostname)" >> $tmpdir/desc

$imgcreate $uimage $tmpdir/desc $ext2_img $target_img


####### CLEANUP ########

echo "Purging $tmpdir + $ext2_img"
rm -fr $tmpdir
rm -fr $ext2_img

echo "Image ready:"
$imginfo $target_img
ls -hl $target_img

