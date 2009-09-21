#!/bin/sh

source tests.inc

cd tests

./wifi     && \
./ethaddr  && \
./ethernet && \
dialog_msg "ALL TESTS PASSED."
