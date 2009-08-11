#!/bin/sh

source tests.inc

cd tests

./ethernet && \
./wifi     && \
dialog_msg "ALL TESTS PASSED."
