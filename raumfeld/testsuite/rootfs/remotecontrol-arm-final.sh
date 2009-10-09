#!/bin/sh

cd /tests

. ../tests.inc

dialog_info "You shouldn't see this message. \
This image is made for final assembly test with no serial \
adapter connected."

TERM=xterm-color ./wifi		>/dev/tty1 && \
TERM=xterm-color ./rotary	>/dev/tty1 && \
TERM=xterm-color ./accel-full	>/dev/tty1 && \
TERM=xterm-color ./battery dock	>/dev/tty1 && \
./touch	&& \
(cat hellokitty.raw > /dev/fb0)

