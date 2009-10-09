# find strongest ad-hoc network around and join it

WIRELESS_IFNAME=wlan0

ifconfig $WIRELESS_IFNAME up

retry=4
ok=0

while [ ! "$ok" = "1" ] && [ ! "$retry" = "0" ]; do
	TMP=$(/sbin/iwlist ${WIRELESS_IFNAME} scan | \
		awk '/ESSID/ { id=$1 } /Mode:/ { mode=$1 } /Signal level/ { print $3 " " id " " mode }' | \
		grep Ad-Hoc | sort | head -n 1)

	ok=1

	if [ -z "${TMP}" ]; then
		err="NO WIRELESS NETWORKS FOUND"
		ok=0
	fi

	ESSID=$(echo ${TMP} | cut -f2 -d\")
	QUALITY=$(echo ${TMP} | cut -f2 -d= | cut -f1 -d' ')
	MIN_QUALITY=-35

	if [ ${MIN_QUALITY} -gt ${QUALITY} ]; then
		err="SIGNAL LEVEL $QUALITY TOO WEAK ($MIN_QUALITY required) -- ESSID $ESSID"
		ok=0
	fi

	retry=$(($retry - 1))
done

if [ ! "$ok" = "1" ]; then
	dialog_err "$err"
fi

