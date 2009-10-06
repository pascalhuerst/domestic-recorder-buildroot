#!/bin/sh

source tests.inc

cd tests

./wifi     		&& \
./ethaddr  		&& \
./ethernet 		&& \
./audio		 	&& \
./nand     		&& \
./zerosetup-button 	&& \
dialog_msg "ALL TESTS PASSED."

./test-menu

