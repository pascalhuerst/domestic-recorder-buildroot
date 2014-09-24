RELPATH=../
INPUT_TEST=/input_test
PINS_TEST=/test_jig
TEST_HOST_WIRELESS=192.168.23.1

kill_leds() {
	killall -q leds-blink
	killall -q leds-blink-so
}

led_on() {
	num=$1
	test -d /sys/class/leds/raumfeld:$num && echo 1 > \
		/sys/class/leds/raumfeld:$num/brightness
	test -d /sys/class/leds/alix:$num && echo 1 > \
		/sys/class/leds/alix:$num/brightness
}

led_off() {
	num=$1
	test -d /sys/class/leds/raumfeld:$num && echo 0 > \
		/sys/class/leds/raumfeld:$num/brightness
	test -d /sys/class/leds/alix:$num && echo 0 > \
		/sys/class/leds/alix:$num/brightness
}

is_model() {
         test -n "$(grep -i "$1" /proc/device-tree/model)"
         return $?
}

is_not_model() {
         if is_model "$1"; then
            return 1
         fi
         return 0
}
