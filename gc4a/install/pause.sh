#!/bin/sh

MAC=1C:99:4C:EF:50:F0
TOKEN=f9681c994cef50f08957e13b478a2f863b0e8ed9f813f31d79f842b2
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
CAST_NAME="Raumfeld Connector"

dbus-send --system --dest=com.streamunlimited.StreamCastDaemon1 --print-reply /com/streamunlimited/StreamCastDaemon1 com.streamunlimited.StreamCastDaemon1.NotifyUserAction uint32:2
