#!/bin/sh

source tests.inc

cd tests

./leds-blink 1 &
pid=$!

./harddisk || touch /tmp/test-failed

if [ -f /tmp/test-failed ]; then
        kill $pid
        ./leds-blink 2
fi

reboot

