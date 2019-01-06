#!/bin/sh

COUNT=0

row_on() {
        R0=$1
        R1=$((R0*4))
        R2=$((R1+1))
        R3=$((R2+1))
        R4=$((R3+1))
        led_on $R1
        led_on $R2
        led_on $R3
        led_on $R4
}

row_off() {
        R0=$1
        R1=$((R0*4))
        R2=$((R1+1))
        R3=$((R2+1))
        R4=$((R3+1))
        led_off $R1
        led_off $R2
        led_off $R3
        led_off $R4
}


led_on() {
        ADDR=$1
        R=$((ADDR+128)); T=$(printf "\\x%x" "$R");  echo -e $T > /dev/espi_led
}

led_off() {
        ADDR=$1
        R=$((ADDR+0)); T=$(printf "\\x%x" "$R");  echo -e $T > /dev/espi_led
}

inc_progress() {
	row_on $COUNT
	COUNT=$((COUNT+1))
}

mount_stick() {
        mounted=false

        while [ "$mounted" = false ]; do

                if (lsblk | grep sda); then
                        echo "Found /dev/sda1. Mounting to /media"
                        mount /dev/sda1 /media
                        mounted=true;
                else
                        echo "Waiting for /dev/sda1 to appear..."
                        sleep 1
                fi
        done
}

mount_stick
exit



modprobe espi_driver
inc_progress

echo -e ',50M,c,*,,700M,83,,,,83\n' >  sfdisk -f /dev/mmcblk0
inc_progress
mkfs.fat /dev/mmcblk0p1
inc_progress
mkfs.ext4 -L rootfs /dev/mmcblk0p2
inc_progress
mkfs.ext4 -L data /dev/mmcblk0p3
inc_progress

mkdir -p /mnt/stick
mkdir -p /mnt/boot
mkdir -p /mnt/data
mkdir -p /mnt/rootfs
inc_progress

mount /dev/sda1 /mnt/stick
mount /dev/mmcblk0p1 /mnt/boot
mount /dev/mmcblk0p2 /mnt/rootfs
mount /dev/mmcblk0p3 /mnt/data
inc_progress

gunzip -c /mnt/stick/rootfs.tar.gz | tar -C /mnt/rootfs/ -xvf -
sync
inc_progress

cp /mnt/stick/u-boot.img /mnt/boot
cp /mnt/stick/MLO /mnt/boot
sync
inc_progress

umount /dev/sda1
umount /dev/mmcblk0p1
umount /dev/mmcblk0p2
umount /dev/mmcblk0p3
inc_progress


