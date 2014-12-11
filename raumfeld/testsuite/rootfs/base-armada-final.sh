#!/bin/sh

# Final script for end of line tests on Raumfeld Expand 2


source tests.inc

cd /tests

led_off 1
led_off 2
led_off 3


# Enable the internal USB port
if is_model "Base"; then
    echo 50 > /sys/class/gpio/export
    echo out > /sys/class/gpio/gpio50/direction
    echo 1 > /sys/class/gpio/gpio50/value
fi

# Load modules
modprobe rt2800usb


echo "*********** Raumfeld Tests starting ********"

# Buttons (Setup, Reset)
kill_leds
./leds-blink-so 1 &
echo "Press the SETUP button (1)."
$INPUT_TEST key_setup
echo "Press the RESET button (2)."
$INPUT_TEST key_f3

# WiFi
kill_leds
./leds-blink-so 2 &
./wifi_managed_ping factory_test
if [ $? -ne 0 ]; then
    kill_leds
    ./leds-blink-so 2 1 &
    exit 1
fi

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
led_on 3


echo "*********** Raumfeld Tests success ********"

exit 0
