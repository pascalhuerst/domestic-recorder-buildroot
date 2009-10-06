# find strongest ad-hoc network around and join it

WIRELESS_IFNAME=wlan0

ifconfig $WIRELESS_IFNAME up

TMP=$(/sbin/iwlist ${WIRELESS_IFNAME} scan | awk '/ESSID/ { id=$1 } /Mode:/ { mode=$1 } /Signal level/ { print $3 " " id " " mode }' | grep Ad-Hoc | sort | head -n 1)

if [ -z "${TMP}" ]; then
	dialog_err "NO WIRELESS NETWORKS FOUND"
	exit 1
fi

ESSID=$(echo ${TMP} | cut -f2 -d\")
QUALITY=$(echo ${TMP} | cut -f2 -d= | cut -f1 -d' ')
MIN_QUALITY=-35

