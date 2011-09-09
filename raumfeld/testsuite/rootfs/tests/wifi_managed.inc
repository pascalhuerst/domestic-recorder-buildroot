# find strongest ad-hoc network around and join it

WIRELESS_IFNAME=wlan0

ifconfig $WIRELESS_IFNAME up

retry=10
ok=0

# we search for the highest quality net named RaumfeldFactoryTest

while [ ! "$ok" = "1" ] && [ ! "$retry" = "0" ]; do
	TMP=$(/sbin/iwlist ${WIRELESS_IFNAME} scan | \
		/wireless_scan -m | grep -i RaumfeldFactoryTest | sort | head -n 1)

	ok=1

	if [ -z "${TMP}" ]; then
		err="NO WIRELESS NETWORKS FOUND"
		ok=0
	fi

	retry=$(($retry - 1))
done

if [  "$ok" = "1" ]; then
  dialog_info "RaumfeldFactoryTest found, now connecting"
fi

if [ ! "$ok" = "1" ]; then
	dialog_err "$err"
fi

