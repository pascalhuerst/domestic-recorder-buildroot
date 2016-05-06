#! /bin/sh

# Script generates device specific token based on wlan or eth address and company id
# Comapny id is 4 digits hex number generated on authentication server
# Please contact authentication server administrator for company id


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

a=`echo -n "$mac" | tr -d ':'`

id='f968'
token=`cat /etc/raumfeld/gc4a_token`
if [ -e "/etc/raumfeld/gc4a_token" ]; then
    echo "WARNING! Token is already set"
    echo "value = $token"
    echo "remove /etc/raumfeld/gc4a_token to recreate a new one"
    norandom=f968$a
    subtoken=${token:0:16}
    if [ $subtoken = $norandom ]; then
        echo "token seems ok"
    else
        echo "ERROR!, token doesn't match mac address"
        echo "token on this device is: $token"
        echo "token should start with: $norandom"
    fi
    exit 1
fi

b=`dd if=/dev/urandom bs=20 count=1 2> /dev/null | hexdump | sed 's:^[^ $]*::g' | tr -d ' \n'`;

fw_setconst 'token' "$id$a$b" &>/dev/null
if [ $? -eq 0 ]; then
         echo "Token stored"
else
         echo "Device doesn't have const partition, token generated for
this device"
fi

echo "Token: $id$a$b"
echo "$id$a$b" > /etc/raumfeld/gc4a_token
