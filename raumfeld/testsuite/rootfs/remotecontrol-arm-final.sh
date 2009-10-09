#!/bin/sh

cd /tests

. ../tests.inc

# different behaviour in case the test was started via ssh
if [ "$1" = "ssh" ]; then
	./framebuffer &&	\
	./rotary &&		\
	./accel-full &&		\
	./touch &&		\
	./battery

	test_result

	exit 0
fi

./wifi-connect

dialog_msg "You shouldn't see this message. \
This image is made for final assembly test with no serial \
adapter connected. This image will only wait for remote ssh connection"

