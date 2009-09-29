#!/bin/sh

if [ x`grep : /var/raumfeld-test/macaddr.list | wc -l` = x0 ]; then
	gmessage -nearmouse "SYNC IS NEEDED. No more MAC addresses."
	exit 1
fi

gksudo /usr/share/raumfeld-test/setup.sh test

gnome-terminal -e /usr/share/raumfeld-test/usb.sh

