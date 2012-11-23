#!/bin/sh

export PATH="/sbin:/usr/sbin:$PATH"

echo "Booted to initramfs."

hw=`cat /proc/cpuinfo | grep ^Hardware | cut -f 3 -d' '`

if [ -z "$hw" ]; then
    hw=`cat /proc/cpuinfo | grep ^model\ name | cut -f 3 -d' '`
fi

offset="5128192"  # default value
offset_v2="8658944"

case "$hw" in
    AM33XX)
	arch="armada"
	img="connect2.img"
        offset=$offset_v2
        ;;
    Controller)
	arch="arm"
	img="control.img"
        bootloader="raumfeld-controller.bin"
	;;
    Connector)
	arch="arm"
	img="connect.img"
        bootloader="raumfeld-connector.bin"
	;;
    Speaker)
	arch="arm"
	img="speaker.img"
        bootloader="raumfeld-speaker.bin"
	;;
    Geode*)
	arch="geode"
	img="base.img"
        bios="raumfeld-base.rom"
	;;
    *)
	img="uImage"
	echo "unknown hardware type '$hw'"
	;;
esac

if [ "$(grep raumfeld-update /proc/cmdline)" ]; then
    param=$(cat /proc/cmdline | sed -e 's/^.*raumfeld-update=//' -e 's/ .*$//')
    img=$(echo $param | cut -d, -f1)
    numfiles=$(echo $param | cut -d, -f2)

    echo "Image name $img ($numfiles files)"
    echo "Performing software update ..."

    mkdir -p /mnt
    mkdir -p /update

    case "$arch" in
	arm)
	    mount -t ubifs -o rw ubi:RootFS /mnt
	    mount -t ubifs -o ro ubi0:Updates /update
	    update=/update/$img
	    ;;
	geode)
	    mount -t ext3 -o rw,data=writeback /dev/hda2 /mnt
	    mount -t ext3 -o rw,data=writeback /dev/hda1 /mnt/boot
	    update=/mnt/update/$img
	    ;;
	*)
	    echo "unknown architecture '$arch'"
	    ;;
    esac

    if [ -n "$bootloader" ]; then
        gunzip -c $update | tar x ./tmp/$bootloader
	echo "Checking the boot-loader ..."
        (cd /tmp; /update-uboot.sh; rm -f $bootloader)
    fi

    if [ -n "$bios" ]; then
        gunzip -c $update | tar x ./tmp/$bios
	echo "Checking the BIOS ..."
        (cd /tmp; /update-coreboot.sh; rm -f $bios)
    fi

    cd /mnt
    raumfeld-extract-update $update $numfiles
    cd /
    sync

    case "$arch" in
	arm)
            umount /update
	    umount /mnt
	    ;;
	geode)
            sleep 5
            umount /mnt/boot
            umount /mnt
	    ;;
	*)
	    echo "unknown architecture '$arch'"
	    ;;
    esac

    echo "Rebooting ..."
    reboot

else
    echo "Image name $img"
    echo "Waiting for USB device to appear ..."

    while [ -z "$(grep sda /proc/partitions)" ]; do
	sleep 1
    done

    # It takes a while for partitions to be recognized after the disk
    # was found.  Sleep three more seconds...
    sleep 3

    mkdir /usb

    mount /dev/sda1 /usb || mount /dev/sda /usb
    losetup -o $offset /dev/loop0 /usb/$img

    mkdir /rootfs
    mount -t ext2 -o ro /dev/loop0 /rootfs

    echo "Jumping to the newly mounted rootfs"
    chroot /rootfs /init.sh
fi

# shouldn't ever get here
exec /bin/sh
