#!/bin/sh

if [ ! -z "$(grep -i "Connector" /proc/device-tree/model)" ]; then

        echo "init script not yet used for Connector. We send you to prompt"
        exit 0
fi

echo "test script for basic IO Board testing"
source tests.inc

cd /tests

led_off 1
led_off 2

echo "*********** Raumfeld Tests starting ********"


kill_leds
./leds-blink-so 1 &
./armada-button

if [ ! -z "$(grep -i "Speaker L" /proc/device-tree/model)" ] || [ ! -z "$(grep -i "One" /proc/device-tree/model)" ]; then
	kill_leds
	./leds-blink 4 &
	$INPUT_TEST rotary_cw

	kill_leds
	./leds-blink 5 &
	$INPUT_TEST rotary_ccw
fi

#wifi test not needed in this case
#kill_leds
#./leds-blink-so 2 &
#./wifi_managed_ping factory_test
#if [ $? -ne 0 ]; then
#    kill_leds
#    ./leds-blink-so 2 1 &
#    exit 1
#fi

kill_leds
./leds-blink-so 3 &
./ethernet_armada 
if [ $? -ne 0 ]; then
    kill_leds
    ./leds-blink-so 3 1 &
    exit 1
fi

#audiotest not needed
#kill_leds
#./leds-blink-so 4 &
#./audio-test-armada
#if [ $? -ne 0 ]; then
#    kill_leds
#    ./leds-blink-so 4 1 &
#    exit 1
#fi

#nand flashing not needed
#kill_leds
#./leds-blink 1 &
#./nand_armada
#if [ $? -ne 0 ]; then
#    kill_leds
#    ./leds-blink-so 5 1 &
#    exit 1
#fi

/update-uboot-armada.sh

kill_leds

led_on 1
led_on 2

#./audio-speaker-armada

echo "*** Updating u-boot *****"
/update-uboot-armada.sh

echo "*********** Raumfeld Tests success ********"

exit 0
