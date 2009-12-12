#!/bin/sh

mode=$1
wlan=$(grep wlan /proc/net/dev | cut -f 1 -d:)

case $mode in
	test)
		killall wpa_supplicant
		killall dhclient
		sleep 3
		iwconfig $wlan mode ad-hoc
		iwconfig $wlan essid $(hostname)
		ifconfig $wlan 192.168.23.1
		
		ifconfig eth0 10.0.0.1

		;;
	normal)
		dhclient eth0
		;;
	*)
		echo "wadd?"
		;;
esac

