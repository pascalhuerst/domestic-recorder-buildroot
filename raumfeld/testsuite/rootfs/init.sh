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

if [ -x /sbin/udevd ]; then
    /sbin/udevd --daemon
fi

rm -fr /var/empty
mkdir -p /var/empty
chmod 755 /var/empty
mkdir /var/lock

export TERM=xterm-color
dmesg -n 1

echo -n "Raumfeld firmware version "; cat /etc/raumfeld-version

read -p "Press Enter to interrupt startup ..." -t3 && exec /bin/sh

/start-test.sh

exec /bin/sh
