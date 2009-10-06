#!/bin/sh

source tests.inc

cd tests

./wifi     		&& \
./ethernet 		&& \
./hda1     		&& \
dialog_msg "ALL TESTS PASSED."

./test-menu

