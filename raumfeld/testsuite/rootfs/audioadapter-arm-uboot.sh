#!/bin/sh

source tests.inc

cd tests

./leds-blink 1 &
pid=$!

./nand || touch /tmp/test-failed
/flash-uboot.sh

if [ -f /tmp/test-failed ]; then
	kill $pid
	./leds-blink 2
fi


reboot

