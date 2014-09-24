#!/bin/sh

# potentially update the boot-loader
./update-uboot.sh

source tests.inc

COLOR="ffff"

(tests/init_flash || echo "ERROR! Failed to initialize flash"; exit 1) | \
    /percent 2023 | \
    /progress_fb 0 0 20 136 $COLOR

(tests/copy_rootfs || echo "ERROR! Failed to copy files to flash"; exit 1) | \
    /percent `cat /rootfs.tgz.numfiles` | \
    /progress_fb 0 136 20 136 $COLOR

reboot
