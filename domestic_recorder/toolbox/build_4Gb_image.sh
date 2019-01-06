#!/bin/bash

FILE=4gb_card.img

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Build empty file"
#read -p "Continue" yn
dd if=/dev/zero of=$FILE bs=1M count=4096 && sync
#chmod 777 $FILE

echo "Setup Loop Device"
#read -p "Continue" yn
losetup /dev/loop0 $FILE

echo "Write partitiontable"
#read -p "Continue" yn
echo -e '0,9,c,*\n,124\n' | sfdisk -H 255 -S 63 /dev/loop0

losetup -d /dev/loop0
losetup --partscan /dev/loop0 $FILE

echo "Format Boot Partition"
mkfs.vfat -n BOOT /dev/loop0p1

echo "Format Root Partition"
mkfs.ext3 /dev/loop0p2

mkdir -p /tmp/boot
mkdir -p /tmp/rootfs

echo "Mounting Filesystems"
#read -p "Continue" yn
#mount -o loop,offset=2560 -t auto /path/to/image.dd /mount/point

mount /dev/loop0p1 /tmp/boot
mount /dev/loop0p2 /tmp/rootfs

echo "Copy Kernel, MLO and uBoot to target partition"
#read -p "Continue" yn
cp /home/paso/development/nonlinear/nonlinux_sysd/output/images/MLO /tmp/boot
cp /home/paso/development/nonlinear/nonlinux_sysd/output/images/u-boot.img /tmp/boot
cp /home/paso/development/nonlinear/nonlinux_sysd/output/images/uImage /tmp/boot

echo "Extract RootFs to target partition"
read -p "Continue" yn
tar -C /tmp/rootfs -xf /home/paso/development/nonlinear/nonlinux_sysd/output/images/rootfs.ext2

echo "Syncing Filesystems"
read -p "Continue" yn
sync

echo "Unmounting Filesystems"
read -p "Continue" yn
umount /dev/loop0p1
umount /dev/loop0p2

rm -fR /tmp/boot
rm -fR /tmp/rootfs

echo "Remove Loop Device"
losetup -d /dev/loop0
