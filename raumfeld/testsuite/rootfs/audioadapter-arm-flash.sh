#!/bin/sh

source tests.inc

cd tests

./nand &&		\
dialog_msg "ALL TESTS PASSED."

