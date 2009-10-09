#!/bin/sh

source tests.inc

cd tests

./wifi     		&& \
./ethaddr  		&& \
./ethernet 		&& \
./nand     		&& \
./rotary		&& \
./zerosetup-button

# no audio test on speaker boards
test -z "$(grep -i speaker /proc/cpuinfo)" && ./audio

test_result

./test-menu

