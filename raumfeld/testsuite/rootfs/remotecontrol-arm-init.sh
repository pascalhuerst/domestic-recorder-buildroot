#!/bin/sh

source tests.inc

cd tests

./framebuffer && 	\
./rotary &&		\
./accel-simple &&	\
./touch &&		\
dialog_msg "ALL TESTS PASSED."

