#!/bin/sh

export PATH="/sbin:/usr/sbin:$PATH"

echo "Booted to initramfs. Now switching over to imgrootfs."

hw=`cat /proc/cpuinfo | grep ^Hardware | cut -f 3 -d' '`

if [ -z "$hw" ]; then
	hw=`cat /proc/cpuinfo | grep ^model\ name | cut -f 3 -d' '`
fi

case "$hw" in
	Controller)
		img="control.img"
		;;
	Connector)
		img="connect.img"
		;;
	Speaker)
		img="speaker.img"
		;;
	Proto)
		img="proto.img"
		;;
	Geode*)
		img="base.img"
		;;
	*)
		img="uImage"
		echo "unknown hardware type '$hw'"
		;;
esac

echo "Image name $img"
echo "Waiting for USB device to appear ..."

while [ -z "$(grep sda /proc/partitions)" ]; do
	sleep 1
done

mkdir /usb

mount /dev/sda1 /usb || mount /dev/sda /usb
losetup -o 5128192 /dev/loop0 /usb/$img

mkdir /rootfs
mount -t ext2 -o ro /dev/loop0 /rootfs

echo "Jumping to the newly mounted rootfs"
chroot /rootfs /init.sh

exec /bin/sh

