#!/bin/sh

export PATH="/sbin:/usr/sbin:$PATH"

echo "Booted to initramfs. Now switching over to imgrootfs."

hw=`cat /proc/cpuinfo | grep ^Hardware | cut -f 3 -d' '`

case "$hw" in
	Controller)
		img="controller.img"
		;;
	Connector)
		img="connector.img"
		;;
	Speaker)
		img="speaker.img"
		;;
	Proto)
		img="proto.img"
		;;
	*)
		img="uImage"
		echo "unknown hardware type '$hw'"
		;;
esac

echo "Image name $img"
echo "Waiting for USB device to appear ..."

while [ -z "$(grep sda1 /proc/partitions)" ]; do
	sleep 1
done

mkdir /usb
mount /dev/sda1 /usb
losetup -o 5128192 /dev/loop0 /usb/$img

mkdir /rootfs
mount -t ext2 /dev/loop0 /rootfs

echo "Jumping to the newly mounted rootfs"
chroot /rootfs /init.sh

exec /bin/sh

