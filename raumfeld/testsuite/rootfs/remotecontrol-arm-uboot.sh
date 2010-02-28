#!/bin/sh

source tests.inc

BASE="/raumfeld-logo.raw"

cd tests

# can be removed as soon as the kernel logo is in place
cat $BASE > /dev/fb0

/flash-uboot.sh
./leds-blink 3
