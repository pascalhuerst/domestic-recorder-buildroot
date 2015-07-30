#!/bin/sh
#
# post-build.sh for the initramfs-arm target

cp raumfeld/initramfs/initramfs.sh $1
cp raumfeld/rootfs/etc/raumfeld-version $1/etc

cat << __END__ > $1/etc/inittab
null::sysinit:/bin/mount -o remount,rw /
null::sysinit:/bin/mount -t proc proc /proc
null::sysinit:/bin/mount -a
console::sysinit:/initramfs.sh
__END__

raumfeld/postbuild-initramfs-cleanup.sh $*
