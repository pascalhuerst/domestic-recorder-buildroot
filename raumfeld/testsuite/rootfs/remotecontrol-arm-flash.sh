#!/bin/sh

source tests.inc

TITLE="NANDFLASH"
DIALOGOPTS="--title $TITLE"

BASE="/raumfeld-logo.raw"
COLOR="ffff"

# can be removed as soon as the kernel logo is in place
cat $BASE > /dev/fb0

(tests/init_flash || dialog_err "ERROR!" $DIALOGOPTS; exit 1) | \
    /percent 2023 | \
    /progress_fb 0 0 20 136 $COLOR

(tests/copy_rootfs || dialog_err "ERROR!" $DIALOGOPTS; exit 1) | \
    /percent `cat /rootfs.tgz.numfiles` | \
    /progress_fb 0 136 20 136 $COLOR

reboot
