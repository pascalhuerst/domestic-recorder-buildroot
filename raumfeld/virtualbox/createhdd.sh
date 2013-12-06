#!/bin/sh

ext2=$1
target=$2

if [ -z "$target" ]; then
	echo "Usage: $0 <ext2-image> <vdi-output-image>"
	exit 1
fi

if [ ! -f "$ext2" ]; then
	echo "File ${ext2} inaccessible"
	exit 1
fi

# target disk size in MB
disksize=512
loopdev=$(losetup -f)

cp ${ext2} rootfs.ext2 
resize2fs rootfs.ext2 ${disksize}M

rm -f hdd.raw
dd if=rootfs.ext2 of=hdd.raw bs=1048576 seek=1

# add aligment padding to make gparted happy
disksize=$((disksize + 1))
dd if=/dev/zero of=hdd.raw bs=1048576 seek=${disksize} count=1

parted hdd.raw --script "mklabel msdos" "mkpart primary ext4 1MiB ${disksize}Mib" "set 1 boot on"

losetup -P ${loopdev} hdd.raw

test -d mnt || mkdir mnt
mount ${loopdev}p1 mnt
extlinux --install mnt/

echo "DEFAULT /boot/bzImage root=/dev/hda1" > mnt/extlinux.conf

sync
umount mnt
losetup -d ${loopdev}

dd if=mbr.bin of=hdd.raw conv=notrunc

rm -f ${target}
VBoxManage convertfromraw hdd.raw ${target} --format VDI

chmod 666 ${target}
rm hdd.raw rootfs.ext2

