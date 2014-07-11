#!/bin/sh

source tests.inc

cd tests

/flash-uboot-armada.sh
./leds-blink 3
