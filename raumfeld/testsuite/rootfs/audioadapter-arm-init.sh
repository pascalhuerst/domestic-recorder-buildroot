#!/bin/sh

source tests.inc

cd tests

./wifi     && \
./ethaddr  && \
./ethernet && \
./audio-loopback && \
./nand     && \
dialog_msg "ALL TESTS PASSED."
