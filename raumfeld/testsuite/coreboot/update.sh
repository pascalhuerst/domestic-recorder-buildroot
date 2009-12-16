#!/bin/sh

mkdir -p /dev/cpu/0
mknod /dev/cpu/0/msr c 202 0
/coreboot/flashrom -w /coreboot/coreboot.bin

