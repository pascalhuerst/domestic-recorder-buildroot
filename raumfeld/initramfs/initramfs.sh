#!/bin/sh

export PATH="/sbin:/usr/sbin:$PATH"

echo "Booted to initramfs."

hw=$(cat /proc/cpuinfo | grep ^Hardware | cut -f 3 -d' ')

if [ -z "$hw" ]; then
    hw=`cat /proc/cpuinfo | grep ^model\ name | cut -f 3 -d' '`
fi

offset="5128192"  # default value

case "$hw" in
    i.MX7)
        arch="i.MX7"
        img="speaker3.img"
        offset="12591104"
        echo "i.MX7 hardware detected"
	;;
    AM33XX)
        arch="armada"
        offset="8658944"
        model=$(cat /proc/device-tree/model | cut -f 2 -d' ')
        echo "Model: $model"

        case "$model" in
            Base)
                img="base2.img"
                ;;
            Connector)
                img="connect2.img"
                ;;
            Soundbar)
                img="speaker2.img"
                mcu="RaumfeldSoundbar.bin"
                dsp="RaumfeldSoundbarDSP.bin"
                ;;
            Sounddeck)
                img="speaker2.img"
                mcu="RaumfeldSounddeck.bin"
                dsp="RaumfeldSounddeckDSP.bin"
                ;;
            *)
                img="speaker2.img"
                ;;
        esac
        ;;
    Controller)
        arch="arm"
        img="control.img"
        ;;
    Connector)
        arch="arm"
        img="connect.img"
        ;;
    Speaker)
        arch="arm"
        img="speaker.img"
        ;;
    Geode*)
        arch="geode"
        img="base.img"
        ;;
    *)
        img="uImage"
        echo "unknown hardware type '$hw'"
        ;;
esac

if [ "$(grep raumfeld-update /proc/cmdline)" ]; then
    param=$(cat /proc/cmdline | sed -e 's/^.*raumfeld-update=//' -e 's/ .*$//')
    # earlier versions used to pass the number of files after the image name separated by a comma
    img=$(echo $param | cut -d, -f1)
    if [ "$(grep rf_silent_update /proc/cmdline)" ]; then
	    silent="-s"
    else
	    silent=""
    fi

    echo "Image name $img"
    echo "Performing software update ..."

    mkdir -p /mnt
    mkdir -p /update

    case "$arch" in
        arm|armada|i.MX7)
            mount -t ubifs -o rw ubi:RootFS /mnt
            mount -t ubifs -o ro ubi0:Updates /update
            update=/update/$img
            ;;
        i.MX7)
            mount -t ubifs -o rw ubi0:RootFS /mnt
            /mnt/usr/sbin/ubiattach /dev/ubi_ctrl -d 1 -m 6
            mount -t ubifs -o rw ubi1:Download /update
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

    if [ -d /mnt/home/chrome ]; then
        echo "Fixing ownership of /home/chrome ..."
        find /mnt/home/chrome -user 368 -exec chown 1000:1000 {} \;
    fi

    echo "Extracting the Raumfeld firmware ..."
    cd /mnt
    raumfeld-extract-update $silent $update
    cd /
    sync

    case "$arch" in
        arm)
            umount /update
            umount /mnt
            ;;

        i.MX7)
            umount /update

            flash_erase /dev/mtd4 0 0
            nandwrite --pad /dev/mtd4 /mnt/boot/uImage.FIT
            rm /mnt/boot/uImage.FIT

            # TODO: Add the code to flash MCU firmware
            # MCU firmware will be different for each speaker device, so select appropriate firmware file from the update image
            # MCU must be brought to "SOM UPGRADE" state before start downloading the firmware

            umount /mnt
            ;;

        armada)
            umount /update

            # 'move' the uImage from the rootfs to its own partition
            flash_erase /dev/mtd6 0 0
            nandwrite --pad /dev/mtd6 /mnt/boot/uImage
            rm /mnt/boot/uImage

            # copy the dts.cramfs to its own partition
            flash_erase /dev/mtd7 0 0
            nandwrite --pad /dev/mtd7 /mnt/tmp/dts.cramfs

            # flash the MCU (on Soundbar and Sounddeck)
            if [ -n "$mcu" ] && [ -e /mnt/tmp/$mcu ]; then
                echo "Flashing the MCU firmware ..."
                /usr/sbin/stm32flash -b 115200 -v -R -i 52,-51,51:-52,-51,51 -e 62 -w /mnt/tmp/$mcu /dev/ttyO5
                if [ $? -ne 0 ]; then
                    echo "Failed to flash the MCU Firmware, resetting MCU."
                    /usr/sbin/stm32flash -b 115200 -R -i 52,-51,51:-52,-51,51 /dev/ttyO5
                    sleep 10
                    echo "Flashing the MCU firmware ..."
                    /usr/sbin/stm32flash -b 115200 -v -R -i 52,-51,51:-52,-51,51 -e 62 -w /mnt/tmp/$mcu /dev/ttyO5
                fi
            fi

            # flash the DSP (on Soundbar and Sounddeck)
            if [ -n "$dsp" ] && [ -e /mnt/tmp/$dsp ]; then
                echo "Flashing the DSP firmware ..."
                rfpfwupdate /dev/ttyO5 2 /mnt/tmp/$dsp 'Power State Switch'=1
            fi

            umount /mnt
            ;;

        geode)
            sleep 5
            umount /mnt/boot
            umount /mnt
            sleep 5
            ;;

        *)
            echo "unknown architecture '$arch'"
            ;;
    esac

    echo "Rebooting ..."
    reboot

elif [ "$(grep ip= /proc/cmdline)" ]; then
    tftp_server=`cat /proc/cmdline | cut -d" " -f3 | cut -d"=" -f2`
    tftp_port=`cat /proc/cmdline | cut -d" " -f4 | cut -d"=" -f2`
    rootfs_abs=`cat /proc/cmdline | cut -d" " -f5 | cut -d"=" -f2`
    rootfs_img=`echo $rootfs_abs | cut -d"/" -f2`


    echo "Booting from network"
    echo "Request for $rootfs_img to $tftp_server ..."

    tftp -g -r $rootfs_abs -l /tmp/$rootfs_img $tftp_server $tftp_port -b 8192
    if [ $? -ne 0 ]; then
	    echo "Error receiving file from $tftp_server, exiting ..."
	    exit 1
    fi

    losetup /dev/loop0 /tmp/$rootfs_img

    mkdir /rootfs
    mount -t ext2 -o ro /dev/loop0 /rootfs

    # work around strange behaviour of the kernel firmware loader
    if [ -d /rootfs/lib/firmware ]; then
        cp -r /rootfs/lib/firmware /lib
    fi

    echo "Jumping to the newly mounted rootfs"
    chroot /rootfs /init.sh

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

    # work around strange behaviour of the kernel firmware loader
    if [ -d /rootfs/lib/firmware ]; then
        cp -r /rootfs/lib/firmware /lib
    fi

    echo "Jumping to the newly mounted rootfs"
    chroot /rootfs /init.sh
fi

# shouldn't ever get here
exec /bin/sh
