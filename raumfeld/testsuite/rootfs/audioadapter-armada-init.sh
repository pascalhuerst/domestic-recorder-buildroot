#!/bin/sh

echo "test script for basic IO Board testing"
source tests.inc

cd /tests

led_off 1
led_off 2

echo "*********** Raumfeld Tests starting ********"


kill_leds
./leds-blink-so 1 &
./armada-button

kill_leds
./leds-blink 4 &
echo "Turn rotary encoder counter-clock-wise."
$INPUT_TEST rotary_cw

kill_leds
./leds-blink 5 &
echo "Turn rotary encoder clock-wise."
$INPUT_TEST rotary_ccw

kill_leds
./leds-blink-so 3 &
echo "Testing ethernet..."
./ethernet_armada
if [ $? -ne 0 ]; then
    kill_leds
    ./leds-blink-so 3 1 &
    exit 1
fi

kill_leds
led_on 1
led_off 2
echo "Testing pins..."
$PIN_TEST
if [ $? -ne 0 ]; then
    ./leds-blink-so 4 1 &
    exit 1
fi

echo "*** Updating u-boot *****"
/update-uboot-armada.sh

kill_leds

led_on 1
led_on 2

echo "*********** Raumfeld Tests success ********"

exit 0
