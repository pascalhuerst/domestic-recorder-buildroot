#!/bin/sh
#
# post-build.sh for the initramfs-armada target

cp raumfeld/initramfs/initramfs.sh $1
cp raumdeld/U-Boot/initramfs-armada-fw-env.config $1/etc/fw_env.config

cat << __END__ > $1/etc/inittab
null::sysinit:/bin/mount -o remount,rw /
null::sysinit:/bin/mount -t proc proc /proc
null::sysinit:/bin/mount -a
console::sysinit:/initramfs.sh
__END__

raumfeld/postbuild-initramfs-cleanup.sh $*
