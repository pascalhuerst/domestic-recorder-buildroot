
chmod 4755 /system/chrome/chrome-sandbox
chmod 0644 /app.conf
chown chrome:chrome /usr/bin/streamcast-launcher
chmod 6755 /usr/bin/streamcast-launcher 
 
#N.B.: this is OTADIR in example dbus setup
# needs to be recrated after a reboot
mkdir -p /tmp/chrome-cache
chown root:chrome /tmp/chrome-cache
chmod 0775 /tmp/chrome-cache

mkdir -p /data/share/chrome
chown chrome:chrome /data/share/chrome
mkdir -p /home/chrome
 
echo '<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN" "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>
  <!-- Service owners -->
  <policy user="root">
    <allow own="com.streamunlimited.StreamCastDaemon1"/>
  </policy>
  <policy user="chrome">
    <allow own="com.streamunlimited.StreamCastAvSettings1"/>
  </policy>
  <!-- Allow anyone to call into the service -->
  <policy context="default">
    <allow send_interface="*"/>
    <allow receive_sender="*"/>
    <allow receive_interface="*"/>
  </policy>
</busconfig>' > /etc/dbus-1/system.d/gc4a.conf
 
echo 'ctl.soundbar {
	type rfpd
	socket "/dev/rfpd.socket"
	debug "syslog 0x0f"
}

pcm.default pcm.socket

pcm.socket {
    type uds
    path /tmp/udsplug/socket
}

ctl.socket {
    type hw
    card 1
}' > /etc/asound.conf

#check if saved token is the correct one
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

norandom=f968$a
token=`cat /etc/raumfeld/gc4a_token`
subtoken=${token:0:16}
if [ $subtoken = $norandom ]; then
    echo "token seems ok"
else

    echo "ERROR, token doesn't match mac address"
    echo "token on this device is: $token"
    echo "token should start with: $norandom"
    echo "run /install/gettoken.sh on the host to create a valid token and let it register by the backend guys"
fi
