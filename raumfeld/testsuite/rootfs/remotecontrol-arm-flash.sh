#!/bin/sh

source tests.inc

TITLE="NANDFLASH"
DIALOGOPTS="--title $TITLE"

BASE="/raumfeld-logo.raw"
COLOR="ffff"

(tests/init_flash || dialog_err "ERROR!" $DIALOGOPTS; exit 1) | \
    /percent 2023 | \
    /progress_fb $BASE 0 0 20 136 $COLOR

(tests/copy_rootfs || dialog_err "ERROR!" $DIALOGOPTS; exit 1) | \
    /percent `cat /rootfs.tgz.numfiles` | \
    /progress_fb $BASE 0 136 20 136 $COLOR

reboot
