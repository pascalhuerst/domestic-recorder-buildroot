#!/bin/sh

# Final script for end of line tests, usually fully assembled.
# Mostly the same for connector and speakers.


source tests.inc

cd /tests

led_off 1
led_off 2

echo "*********** Raumfeld Tests starting ********"


kill_leds
./leds-blink-so 1 &
./armada-button

if [ -n "$(grep -i "Cube" /proc/device-tree/model)" ]; then
    kill_leds
    ./leds-blink 4 &
    echo "Press Volume Down button (-)."
    $INPUT_TEST key_volume_down

    kill_leds
    ./leds-blink 5 &
    echo "Press Volume Up button (+)."
    $INPUT_TEST key_volume_up
fi

if [ -n "$(grep -i "One" /proc/device-tree/model)" ]; then
    kill_leds
    ./leds-blink 6 &
    ./station-buttons
fi

if [ -n "$(grep -i "Speaker L" /proc/device-tree/model)" ] || [ -n "$(grep -i "One" /proc/device-tree/model)" ]; then
    kill_leds
    ./leds-blink 4 &
    echo "Turn rotary encoder clock-wise."
    $INPUT_TEST rotary_cw

    kill_leds
    ./leds-blink 5 &
    echo "Turn rotary encoder counter-clock-wise."
    $INPUT_TEST rotary_ccw
fi

kill_leds
./leds-blink-so 2 &
./wifi_managed_ping factory_test
if [ $? -ne 0 ]; then
    kill_leds
    ./leds-blink-so 2 1 &
    exit 1
fi

if [ -n "$(grep -i "Test Jig" /proc/device-tree/model)" ]; then
    kill_leds
    led_on 1
    led_off 2
    echo "Testing pins..."
    if ! $PINS_TEST; then
        ./leds-blink-so 3 1 &
        exit 1
    fi
else
    # do WIFI tests on all other modesl
    kill_leds
    ./leds-blink-so 3 &
    ./ethernet_armada
    if [ $? -ne 0 ]; then
        kill_leds
        ./leds-blink-so 3 1 &
        exit 1
    fi
fi

if [ -n "$(grep -i "Connector" /proc/device-tree/model)" ]; then
    kill_leds
    ./leds-blink-so 4 &
    ./audio-test-armada
    if [ $? -ne 0 ]; then
        kill_leds
        ./leds-blink-so 4 1 &
        exit 1
    fi
fi

if [ -z "$(grep -i "Test Jig" /proc/device-tree/model)" ]; then
    kill_leds
    ./leds-blink 1 &
    ./nand_armada
    if [ $? -ne 0 ]; then
        kill_leds
        ./leds-blink-so 5 1 &
        exit 1
    fi
fi

/update-uboot-armada.sh

kill_leds

led_on 1
led_on 2

if [ -z "$(grep -i "Test Jig" /proc/device-tree/model)" ]; then
    ./audio-speaker-armada
fi

echo "*********** Raumfeld Tests success ********"


exit 0
