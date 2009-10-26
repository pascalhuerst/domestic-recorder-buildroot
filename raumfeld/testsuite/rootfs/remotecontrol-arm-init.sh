#!/bin/sh

source tests.inc

cd tests

./framebuffer && 	\
./rotary &&		\
./accel-simple &&	\
./touch &&		\
./wifi &&		\
./battery &&		\
./nand

test_result

./test-menu

