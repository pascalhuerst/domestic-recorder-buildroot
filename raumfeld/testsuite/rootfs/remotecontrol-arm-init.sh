#!/bin/sh

source tests.inc

cd tests

./framebuffer && 	\
./rotary &&		\
./accel-simple &&	\
./touch &&		\
./wifi &&		\
./battery &&		\
dialog_msg "ALL TESTS PASSED."

