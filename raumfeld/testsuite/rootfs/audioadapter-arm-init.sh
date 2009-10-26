#!/bin/sh

source tests.inc

cd tests

if [ ! -z "$(grep -i speaker /proc/cpuinfo)" ]; then
	./wifi			&&
	./ethaddr  		&& \
	./ethernet 		&& \
	./rotary		&& \
	./nand     		&& \
	./zerosetup-button
else
	./wifi     		&& \
	./ethaddr  		&& \
	./ethernet 		&& \
	./nand     		&& \
	./audio			&& \
	./zerosetup-button
fi

test_result

./test-menu

