#!/bin/sh

source tests.inc

cd tests

exit

./wifi     		&& \
./ethaddr  		&& \
./ethernet 		&& \
./audio		 	&& \
./nand     		&& \
./zerosetup-button

test_result

./test-menu

