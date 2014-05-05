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
if is_not_model "Test Jig"; then
    echo "Press the POWER button (3)."
    $INPUT_TEST key_power
fi

# Volume Buttons (only on Cube)
if is_model "Cube"; then
    kill_leds
    ./leds-blink 4 &
    echo "Press Volume Down button (-)."
    $INPUT_TEST key_volume_down

    kill_leds
    ./leds-blink 5 &
    echo "Press Volume Up button (+)."
    $INPUT_TEST key_volume_up
fi

# Station Buttons (only on One)
if is_model "One"; then
    kill_leds
    ./leds-blink 6 &
    ./station-buttons
fi

# Rotary Encoder (only on Speaker L and One)
if is_model "Speaker L" || is_model "One"; then
    kill_leds
    ./leds-blink 4 &
    echo "Turn rotary encoder clock-wise."
    $INPUT_TEST rotary_cw

    kill_leds
    ./leds-blink 5 &
    echo "Turn rotary encoder counter-clock-wise."
    $INPUT_TEST rotary_ccw
fi

# Pin Connectors (only on the Test JIG)
if is_model "Test Jig"; then
    kill_leds
    led_on 1
    led_off 2
    echo "Testing pins..."
    $PINS_TEST
    if [ $? -ne 0 ]; then
        kill_leds
        ./leds-blink-so 2 1 &
        exit 1
    fi
fi

# WiFi (on all models but the Test JIG)
if is_not_model "Test Jig"; then
    kill_leds
    ./leds-blink-so 2 &
    ./wifi_managed_ping factory_test
    if [ $? -ne 0 ]; then
        kill_leds
        ./leds-blink-so 2 1 &
        exit 1
    fi
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

# Audio Loopback (only on Connector)
if is_model "Connector"; then
    kill_leds
    ./leds-blink-so 4 &
    ./audio-test-armada
    if [ $? -ne 0 ]; then
        kill_leds
        ./leds-blink-so 4 1 &
        exit 1
    fi
fi

# NAND flash (on all models but the Test JIG)
if is_not_model "Test Jig"; then
    kill_leds
    ./leds-blink 1 &
    ./nand_armada
    if [ $? -ne 0 ]; then
        kill_leds
        ./leds-blink-so 5 1 &
        exit 1
    fi
fi

# Potentially update the boot-loader
/update-uboot-armada.sh

kill_leds

led_on 1
led_on 2

# Audio output (on all models but the Test JIG)
if is_not_model "Test Jig"; then
    ./audio-speaker-armada
fi

echo "*********** Raumfeld Tests success ********"


exit 0
