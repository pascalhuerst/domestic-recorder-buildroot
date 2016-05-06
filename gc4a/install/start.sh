#!/bin/sh

mac=`cat /sys/class/net/wlan0/address`
if [ -z "$mac" ]; then
        mac=`cat /sys/class/net/eth0/address`
	if [ -z "$mac" ]; then
        	mac=`cat /sys/class/net/eno1/address`
	fi
fi

if [ -z "$mac" ]; then
         echo "Cannot retrieve mac address from wlan0 nor eth0" 1>&2
         exit 1
fi
MAC=$mac
TOKEN=`cat /etc/raumfeld/gc4a_token`

echo "$MAC:$TOKEN"

BOARD_NAME=Connector
PRODUCT_NAME=Raumfeld
DEVICE_MODEL=2
MANUFACTURER=Raumfeld
SERIAL=123
BUILD_NUMBER=2.0
REVISION=2
STABLE_CHANNEL=11
WLAN_INTERFACE=wlan0
AP_INTERFACE=uap0
FACTORY_COUNTRY=DE
FACTORY_LOCALE=de_DE
RELEASE=Release
BOARD_REVISION=2
CAST_NAME=Raumfeld

dbus-send --system --dest=com.streamunlimited.StreamCastDaemon1 --print-reply /com/streamunlimited/StreamCastDaemon1 com.streamunlimited.StreamCastDaemon1.SetPlatformInformation dict:uint32:string:1,$RELEASE,2,$STABLE_CHANNEL,3,$SERIAL,4,$PRODUCT_NAME,5,$DEVICE_MODEL,6,$BOARD_NAME,7,$BOARD_REVISION,8,$MANUFACTURER,9,$BUILD_NUMBER,10,$FACTORY_COUNTRY,11,$FACTORY_LOCALE,12,$WLAN_INTERFACE,13,$AP_INTERFACE,14,$TOKEN,15,$MAC,16,/tmp/chrome-cache
dbus-send --system --dest=com.streamunlimited.StreamCastDaemon1 --print-reply /com/streamunlimited/StreamCastDaemon1 com.streamunlimited.StreamCastDaemon1.Start
