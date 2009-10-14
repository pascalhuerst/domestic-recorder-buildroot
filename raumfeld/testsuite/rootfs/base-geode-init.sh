#!/bin/sh

source tests.inc

cd tests

./leds-blink 1 &
pid=$!

./wifi || touch /tmp/test-failed
./harddisk || touch /tmp/test-failed

kill $pid

if [ -f /tmp/test-failed ]; then
        ./leds-blink 2
fi

./leds-blink 3

