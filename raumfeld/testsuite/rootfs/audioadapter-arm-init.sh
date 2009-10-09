#!/bin/sh

source tests.inc

cd tests

./wifi     		&& \
./ethaddr  		&& \
./ethernet 		&& \
./audio		 	&& \
./nand     		&& \
./rotary		&& \
./zerosetup-button

test_result

./test-menu

