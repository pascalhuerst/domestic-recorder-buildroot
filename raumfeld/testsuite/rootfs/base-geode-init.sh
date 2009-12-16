#!/bin/sh

source tests.inc

cd tests

./leds-blink 1 &
pid=$!

./wifi || touch /tmp/test-failed
./harddisk || touch /tmp/test-failed

kill $pid

if [ -f /tmp/hdd-failed ]; then
	dialog_err "HARDDISK INIT FAILED"
        ./leds-blink 2
fi

dialog_info "All tests passed"
./leds-blink 3

