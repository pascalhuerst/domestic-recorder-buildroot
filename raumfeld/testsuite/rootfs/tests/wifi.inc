# find strongest ad-hoc network around and join it

WIRELESS_IFNAME=wlan0

ifconfig $WIRELESS_IFNAME up

retry=10
ok=0

while [ ! "$ok" = "1" ] && [ ! "$retry" = "0" ]; do
	TMP=$(/sbin/iwlist ${WIRELESS_IFNAME} scan | \
		/wireless_scan | sort | head -n 1)

	ok=1

	if [ -z "${TMP}" ]; then
		err="NO WIRELESS NETWORKS FOUND"
		ok=0
	fi

	QUALITY=$(echo ${TMP} | cut -f1 -d' ')
	ESSID=$(echo ${TMP} | cut -f2 -d' ')
	MIN_QUALITY=-40

	if [ ${MIN_QUALITY} -gt ${QUALITY} ]; then
		err="SIGNAL LEVEL $QUALITY TOO WEAK ($MIN_QUALITY required) -- ESSID $ESSID"
		ok=0
	fi

	retry=$(($retry - 1))
done

if [ ! "$ok" = "1" ]; then
	dialog_err "$err"
fi

