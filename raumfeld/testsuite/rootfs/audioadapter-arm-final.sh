#!/bin/sh

source tests.inc

cd /tests

led_off 1
led_off 2

if [ -n "$(grep -i speaker /proc/cpuinfo)" ]; then

	# TEST PROCEDURE FOR SPEAKERS

	./leds-blink 2  &
	./zerosetup-button
	killall leds-blink

	./leds-blink 4 &
	$INPUT_TEST rotary_cw
	killall leds-blink

	./leds-blink 5 &
	$INPUT_TEST rotary_ccw
	killall leds-blink

	led_off 1
	led_off 2

if [ -n "$(grep -i ": 0401" /proc/cpuinfo)" ]; then
	# Raumfeld One
	./wifi_managed

	led_on 1
	led_on 2
fi
if [ -n "$(grep -i ": 0201" /proc/cpuinfo)" ]; then
	# Speaker L
	./wifi_managed

	led_on 1
	led_on 2
fi

	./audio

	led_on 1
	led_on 2

	# loop thru audio for further production line tests
	./audio-loopback >/dev/null 2>&1 &

else
	./wifi     		&& \
	./audio			&& \
	./zerosetup-button
fi

test_result

exit 1
