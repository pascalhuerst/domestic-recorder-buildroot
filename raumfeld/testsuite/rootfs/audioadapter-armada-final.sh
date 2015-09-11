#!/bin/sh

# Final script for end of line tests, usually fully assembled.
# Mostly the same for connector and speakers.

source tests.inc

cd /tests

led_off 1
led_off 2


# Handle fallback mode
if is_model "fallback"; then
    # If we came up in fallback mode, we have to flash a newer version
    # of u-boot and restart. u-boot flag 'usbboot_once' tells u-boot to
    # boot from usb. Just as if 'reset' is pressed.
    /flash-uboot-armada.sh
    /usr/sbin/fw_setenv "usbboot_once" "yes"
    reboot
fi


# Update the MCU firmware on the Raumfeld Soundbar and Sounddeck
if is_model "Soundbar" || is_model "Sounddeck"; then
    kill_leds
    ./leds-blink 7 &
    ./flash_mcu
    usleep 50000
    ./flash_dsp
fi


# Load modules

modprobe snd-soc-adau1701
modprobe snd-soc-ak4104
modprobe snd-soc-ak5386
modprobe snd-soc-cs4271
modprobe snd-soc-sigmadsp
modprobe snd-soc-sta350
modprobe snd-soc-tas5086
modprobe snd-soc-davinci-mcasp
modprobe snd-soc-edma
modprobe snd-soc-spdif-rx
modprobe snd-soc-spdif-tx
# FIXME: the above should actually be implicitly loaded by the next one
modprobe snd-soc-s800
modprobe mwifiex_sdio


# Check if USB sound card is connected on a Raumfeld One S
if is_model "Element"; then
    modprobe snd-usb-audio
    if test -n "$(cat /proc/asound/cards | grep USB)"; then
        echo "*********** USB Input Test ********"
        cd /raumfeld/factory-tests && ./audio-usb-input &
        kill_leds
        led_on 1
        led_on 2
        exit 0
    fi
fi


echo "*********** Raumfeld Tests starting ********"

# Buttons (Setup, Reset, Power)
kill_leds
./leds-blink-so 1 &

echo "Press the SETUP button (1)."
$INPUT_TEST key_setup

echo "Press the RESET button (2)."
$INPUT_TEST key_f3

if is_model "Soundbar" || is_model "Sounddeck" ; then
    $MCU_TEST set-control 'Power State Switch' 1
    echo "Press the POWER button (3)."
    $MCU_TEST wait-rc-input 0x6b
elif is_not_model "Test Jig"; then
    echo "Press the POWER button (3)."
    $INPUT_TEST key_power
fi

# Volume Buttons (on Cube and One S)
if is_model "Cube" || is_model "Element"; then
    kill_leds
    ./leds-blink 4 &
    echo "Press Volume Down button (-)."
    $INPUT_TEST key_volume_down

    kill_leds
    ./leds-blink 5 &
    echo "Press Volume Up button (+)."
    $INPUT_TEST key_volume_up
fi

# Station Buttons (on One M, One S and Stereo M)
if is_model "One" || is_model "Element" || is_model "Speaker M"; then
    kill_leds
    ./leds-blink 6 &
    ./station-buttons
fi

# Rotary Encoder (on Speaker M/L and One)
if is_model "Speaker M" || is_model "Speaker L" || is_model "One"; then
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
    modprobe snd-usb-audio
    echo "Testing pins and line-in..."
    (cd /raumfeld/factory-tests; ./ioboard-pins && ./audio-line-in)
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


if is_model "Soundbar" || is_model "Sounddeck"; then
    $MCU_TEST set-control 'Power State Switch' 1
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

# Volume Buttons (on Soundbar and Sounddeck)
if is_model "Soundbar" || is_model "Sounddeck"; then
    kill_leds
    ./leds-blink 4 &
    echo "Press Volume Down button (-)."
    $MCU_TEST wait-event-dec 'Master Playback Volume'

    kill_leds
    ./leds-blink 5 &
    echo "Press Volume Up button (+)."
    $MCU_TEST wait-event-inc 'Master Playback Volume'
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

# update the boot-loader
/flash-uboot-armada.sh

kill_leds
led_on 1
led_on 2

# Audio output (on all models but the Test JIG)
if is_not_model "Test Jig"; then
    ./audio-speaker-armada
fi


echo "*********** Raumfeld Tests success ********"

exit 0
