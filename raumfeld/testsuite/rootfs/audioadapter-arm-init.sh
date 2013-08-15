#!/bin/sh

source tests.inc

cd tests

if [ -n "$(grep -i speaker /proc/cpuinfo)" ]; then
	./nand     		&& \
	./wifi			&& \
	./ethaddr  		&& \
	./ethernet 		&& \
	./rotary		&& \
	./zerosetup-button
else
	./nand     		&& \
	./wifi     		&& \
	./ethaddr  		&& \
	./ethernet 		&& \
	./audio			&& \
	./zerosetup-button
fi

./audio-loopback >/dev/null 2>&1 &

test_result

./test-menu

