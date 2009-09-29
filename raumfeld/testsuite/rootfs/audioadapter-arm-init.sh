#!/bin/sh

source tests.inc

cd tests

./wifi     && \
./ethaddr  && \
./ethernet && \
./nand     && \
dialog_msg "ALL TESTS PASSED."
