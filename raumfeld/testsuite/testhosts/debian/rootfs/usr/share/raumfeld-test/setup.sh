#!/bin/sh

mode=$1

case $mode in
	test)
		killall wpa_supplicant
		killall dhclient
		sleep 3
		iwconfig wlan0 mode ad-hoc
		iwconfig wlan0 essid $(hostname)
		ifconfig wlan0 192.168.23.1
		iwconfig wlan1 mode ad-hoc
		iwconfig wlan1 essid $(hostname)
		ifconfig wlan1 192.168.23.1
		
		ifconfig eth0 10.0.0.1

		;;
	normal)
		dhclient eth0
		;;
	*)
		echo "wadd?"
		;;
esac

