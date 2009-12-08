#!/bin/sh

source tests.inc

cd tests

if [ ! -z "$(grep -i speaker /proc/cpuinfo)" ]; then
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

test_result

./test-menu

