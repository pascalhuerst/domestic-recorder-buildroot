#!/bin/sh
#
# This script waits until $INTERFACE is up and running and reduces its
# transmit power, in order to comply with international standards
#

INTERFACE=wlan0
RESULT=$(cat /sys/class/net/$INTERFACE/operstate)
MODEL=$(cat /proc/device-tree/model)

# Bail out if model is not expand
[ "$MODEL" != "Raumfeld Base (AM33xx)" ] && exit 0

echo -e "$INTERFACE: Waiting for interface to reduce transmit power... "
while [ "$RESULT" != "up" ]; do
	sleep 1
	RESULT=$(cat /sys/class/net/$INTERFACE/operstate)
done

/usr/sbin/iw dev $INTERFACE set txpower fixed 1800
echo "$INTERFACE: Transmit power reduced!"
