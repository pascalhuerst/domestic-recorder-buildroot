#!/bin/sh

mkdir -p /proc
mkdir -p /sys
mount -n proc /proc -t proc
mount -n sys /sys -t sysfs
mount -n -t tmpfs tmpfs /tmp
mount -n -t tmpfs tmpfs /var

# devtmpfs does not get automounted for initramfs
mount -t devtmpfs devtmpfs /dev
exec 0</dev/console
exec 1>/dev/console
exec 2>/dev/console

export PATH="/sbin:/usr/sbin:$PATH"
/lib/udev/udevd --daemon

if [ ! -z "$(grep Geode /proc/cpuinfo)" ]; then
	# modules for GEODE
	modprobe ath5k
else
	# modules for ARM
	modprobe eeti_ts flip_y=1
	modprobe pxamci
	modprobe libertas_sdio
	modprobe wire.ko delay_coef=3
	modprobe w1-gpio.ko
	modprobe w1_ds2760.ko
	modprobe ds2760_battery.ko pmod_enabled=1 rated_capacity=10
fi

rm -fr /var/empty
mkdir -p /var/empty
chmod 755 /var/empty
mkdir /var/lock
/etc/init.d/S50sshd start

export TERM=xterm-color
dmesg -n 1
/start-test.sh
exec /bin/sh
