RELPATH=../
INPUT_TEST=/input_test
TEST_HOST_ETHERNET=10.0.0.1
TEST_HOST_WIRELESS=192.168.1.51

function dialog_msg() {
	text=$1; shift
	DIALOGRC=$RELPATH/dialogrc.msg dialog $* --msgbox "$text" 20 40
}

function dialog_err() {
	text=$1; shift
	DIALOGRC=$RELPATH/dialogrc.err dialog $* --msgbox "$text" 20 40
}

function dialog_success() {
	text=$1; shift
	DIALOGRC=$RELPATH/dialogrc.success dialog $* --infobox "$text" 20 40
}

function dialog_info() {
	text=$1; shift
	DIALOGRC=$RELPATH/dialogrc.msg dialog $* --infobox "$text" 20 40
}


function dialog_progress {
	text=$1; shift
	DIALOGRC=$RELPATH/dialogrc.msg dialog $* --gauge "$text" 10 40
}

