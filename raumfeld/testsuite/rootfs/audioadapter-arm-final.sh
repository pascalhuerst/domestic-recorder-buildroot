#!/bin/sh

source tests.inc

cd tests

./wifi-connect

dialog_msg "You shouldn't see this message. " \
	"This image is made for final assembly test with no serial " \
	"adapter connected. This image will only wait for remote ssh connection "

