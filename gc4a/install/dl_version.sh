#!/usr/bin/env sh

#retrive token
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

macid=`echo -n "$mac" | tr -d ':'`


updateurl='http://testmedia.bag.software/GC4A'
latestversionfile='latestversion'

#retrieve latest version references
latestversiononserver=`wget -qO- $updateurl/$latestversionfile`

lastestversion=`echo $latestversiononserver | cut -f 1 -d ' ' `
package=`echo $latestversiononserver | cut -f 2 -d ' ' `
versionurl=$updateurl/$package

#check if we already have something install
if [ -e "/raumfeld/gc4a/currentversion" ]; then
    currentversion=`cat /raumfeld/gc4a/currentversion`
    echo $currentversion
else
    currentversion='0.0'
    echo has never been installed, running full installation
fi

if [ "$currentversion" != "$latestversion" ]; then
    echo fetching latest version from $versionurl
    #wget $versionurl
    echo $lastestversion > /raumfeld/gc4a/currentversion
    token=`wget -qO- $updateurl/tokens/$macid`
    echo Token for this machine is: $token
    echo $token > /etc/raumfeld/gc4a_token

fi
