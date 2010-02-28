#!/bin/sh

source tests.inc

cd tests

/flash-uboot.sh
./leds-blink 3
