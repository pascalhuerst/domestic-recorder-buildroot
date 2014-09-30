#!/bin/sh
#
# post-build.sh for the initramfs-arm target

# extra content for updating the boot-loader

echo "Building and installing tools for boot-loader update..."
GCC=$2gcc
$GCC -o $1/update-boardrev -Wall raumfeld/testsuite/bootloader/update-boardrev.c

cp raumfeld/testsuite/rootfs/update-uboot.sh $1
cp raumfeld/rootfs-arm/etc/fw_env.config $1/etc

# below is the generic part

cp raumfeld/initramfs/initramfs.sh $1
cp raumfeld/rootfs/etc/raumfeld-version $1/etc

cat << __END__ > $1/etc/inittab
null::sysinit:/bin/mount -o remount,rw /
null::sysinit:/bin/mount -t proc proc /proc
null::sysinit:/bin/mount -a
console::sysinit:/initramfs.sh
__END__

raumfeld/postbuild-initramfs-cleanup.sh $*
