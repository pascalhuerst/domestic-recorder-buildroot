#!/bin/sh

gksudo /usr/share/raumfeld-test/setup.sh normal

/usr/share/raumfeld-test/do_sync.sh

echo $?

if [ $? = 0 ]; then
	gmessage -nearmouse "sync ok."
else
	gmessage -nearmouse "SYNC FAILED! check network connections."
fi

