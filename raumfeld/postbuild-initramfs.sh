#!/bin/sh
#
# post-build.sh for the initramfs-arm target

cp raumfeld/initramfs/initramfs.sh $1

cat << __END__ > $1/etc/inittab
null::sysinit:/bin/mount -o remount,rw /
null::sysinit:/bin/mount -t proc proc /proc
null::sysinit:/bin/mount -a
console::sysinit:/initramfs.sh
__END__

