#!/bin/sh

# potentially update the boot-loader

#disabled u boot for now
#./update-uboot.sh

source tests.inc

led_off 1
led_off 2

cd tests

kill_leds
./leds-blink 1 &
./nand_armada
if [ $? -ne 0 ]; then
    kill_leds
    ./leds-blink-so 5 1 &
    exit 1
fi


kill_leds

/update-uboot-armada.sh


led_on 1
led_on 2

reboot

