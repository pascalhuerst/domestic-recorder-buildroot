RELPATH=../
INPUT_TEST=/input_test
PINS_TEST=/test_jig
TEST_HOST_ESSID="RaumfeldTest"
TEST_HOST_ETHERNET=10.0.0.1
TEST_HOST_WIRELESS=192.168.23.1

IP_ETHERNET=10.0.0.2
IP_WIRELESS=192.168.23.2

dialog_msg() {
	text=$1; shift;
	DIALOGRC=$RELPATH/dialogrc.msg \
	dialog $* --msgbox "$text" 20 40;
}

dialog_err() {
	text=$1; shift;
	DIALOGRC=$RELPATH/dialogrc.err \
	dialog $* --msgbox "$text" 20 40;
	touch /tmp/test-failed
	sleep 3;
}

dialog_success() {
	text=$1; shift;
	DIALOGRC=$RELPATH/dialogrc.success \
	dialog $* --infobox "$text" 20 40;
	sleep 3;
}

dialog_info() {
	text=$1; shift;
	DIALOGRC=$RELPATH/dialogrc.msg \
	dialog $* --infobox "$text" 20 40;
	sleep 3;
}

dialog_progress() {
	text=$1; shift;
	DIALOGRC=$RELPATH/dialogrc.msg \
	dialog $* --gauge "$text" 10 40;
}

test_result() {
	if [ -f /tmp/test-failed ]; then
		dialog_err "ONE OR MORE TESTS FAILED. ALARM."
	else
		dialog_msg "ALL TESTS PASSED."
	fi
}

suspend() {
	echo mem > /sys/power/state
}

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
