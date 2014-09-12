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

if [ -n "$(grep Geode /proc/cpuinfo)" ]; then
    # modules for GEODE
    modprobe ath5k
elif [ -n "$(grep AM33XX /proc/cpuinfo)" ]; then
    # modules for ARMADA
    modprobe snd-soc-adau1701
    modprobe snd-soc-ak4104
    modprobe snd-soc-ak5386
    modprobe snd-soc-cs4271
    modprobe snd-soc-sigmadsp
    modprobe snd-soc-sta350
    modprobe snd-soc-tas5086
    modprobe snd-soc-davinci-mcasp
    # FIXME: the above should actually be implicitly loaded by the next one
    modprobe snd-soc-s800
    modprobe mwifiex_sdio
else
    # modules for legacy ARM
    modprobe pxamci
fi

rm -fr /var/empty
mkdir -p /var/empty
chmod 755 /var/empty
mkdir /var/lock

export TERM=xterm-color
dmesg -n 1

read -p "Press Enter to interrupt startup ..." -t3 && exec /bin/sh

/start-test.sh

exec /bin/sh
