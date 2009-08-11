#!/bin/sh

mkdir -p /proc
mkdir -p /sys
mount proc /proc -t proc
mount sys /sys -t sysfs
mount devpts /dev/pts -t devpts
export PATH="/sbin:/usr/sbin:$PATH"
udevd --daemon

modprobe eeti_ts flip_y=1
modprobe pxamci
modprobe libertas_sdio
modprobe wire.ko delay_coef=3
modprobe w1-gpio.ko
modprobe w1_ds2760.ko


############################################################
WIRELESS_DEV=wlan0
iwconfig $WIRELESS_DEV essid bugwerft
iwconfig $WIRELESS_DEV rate 54M
wpa_supplicant -Dwext -i$WIRELESS_DEV -c/etc/wpa_supplicant.conf -B
ifconfig $WIRELESS_DEV 192.168.1.56
############################################################

rm -fr /var/empty
mkdir -p /var/empty
chmod 755 /var/empty
/etc/init.d/S50sshd start

export TERM=xterm-color
dmesg -n 1
/start-test.sh
exec /bin/sh

