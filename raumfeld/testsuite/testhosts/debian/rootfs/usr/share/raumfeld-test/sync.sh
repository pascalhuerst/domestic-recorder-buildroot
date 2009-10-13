#!/bin/sh

gksudo /usr/share/raumfeld-test/setup.sh normal

/usr/share/raumfeld-test/getmacs.sh

ret=$?

if [ $ret = "0" ]; then
	gmessage -nearmouse "sync ok."
else
	ip=$(ifconfig eth0 | grep addr: | grep Mask | cut -f2 -d: | cut -f1 -d' ')
	gmessage -nearmouse "SYNC FAILED! check network connections. IP is $ip"
fi

