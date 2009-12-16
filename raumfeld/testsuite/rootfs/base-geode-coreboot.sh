#!/bin/sh

source tests.inc

/coreboot/update.sh

cd tests
./leds-blink 3

