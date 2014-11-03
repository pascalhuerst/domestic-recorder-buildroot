#!/bin/sh

# Final script for end of line tests, usually fully assembled.
# Mostly the same for connector and speakers.


source tests.inc

cd /tests

led_off 1
led_off 2


echo "*********** Raumfeld Tests starting ********"

# Buttons (Setup, Reset, Power)
kill_leds
./leds-blink-so 1 &
echo "Press the SETUP button (1)."
$INPUT_TEST key_setup
echo "Press the RESET button (2)."
$INPUT_TEST key_f3

# Ethernet
kill_leds
./leds-blink-so 3 &
./ethernet_armada
if [ $? -ne 0 ]; then
    kill_leds
    ./leds-blink-so 3 1 &
    exit 1
fi

# NAND flash
kill_leds
./leds-blink 1 &
./nand_armada
if [ $? -ne 0 ]; then
    kill_leds
    ./leds-blink-so 5 1 &
    exit 1
fi

# update the boot-loader
/flash-uboot-armada.sh

kill_leds
led_on 1
led_on 2


echo "*********** Raumfeld Tests success ********"

exit 0
