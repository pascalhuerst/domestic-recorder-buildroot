#!/bin/sh

source tests.inc

cd tests

./hda1 &&	\
dialog_msg "ALL TESTS PASSED."

