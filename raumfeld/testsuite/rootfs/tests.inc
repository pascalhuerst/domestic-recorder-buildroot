RELPATH=../
INPUT_TEST=/input_test
TEST_HOST_ESSID="RaumfeldTest"
TEST_HOST_ETHERNET=10.0.0.1
TEST_HOST_WIRELESS=192.168.23.1

IP_WIRELESS=192.168.23.2
IP_ETHERNET=10.0.0.2

dialog_msg() {
	text=$1; shift;
	DIALOGRC=$RELPATH/dialogrc.msg dialog $* --msgbox "$text" 20 40;
}

dialog_err() {
	text=$1; shift;
	DIALOGRC=$RELPATH/dialogrc.err dialog $* --msgbox "$text" 20 40;
	sleep 3;
}

dialog_success() {
	text=$1; shift;
	DIALOGRC=$RELPATH/dialogrc.success dialog $* --infobox "$text" 20 40;
	sleep 3;
}

dialog_info() {
	text=$1; shift;
	DIALOGRC=$RELPATH/dialogrc.msg dialog $* --infobox "$text" 20 40;
	sleep 3;
}

dialog_progress() {
	text=$1; shift;
	DIALOGRC=$RELPATH/dialogrc.msg dialog $* --gauge "$text" 10 40;
}

