#!/bin/sh

hw=$(cat /proc/cpuinfo | grep ^model\ name | cut -f 3 -d' ')

case "$hw" in
    Geode*)
        ;;
    *)
	echo "Looks like we are on the wrong hardware, exiting."
	exit 0
esac

# check if an update is needed

bios=$(dmidecode -t bios | grep BIOS\ Revision)
revision=$(echo $bios | sed -e 's/\s*BIOS Revision: //')

# with the old BIOS, dmidecode is not even able to get the revision,
# so we also match the empty string

case "x$revision" in
    x|'x3.0'|'x4.0')
        echo $bios
        echo "Updating the BIOS, cross your fingers ..."
        flashrom -p internal:boardmismatch=force -w raumfeld-base.rom
        ;;
    *)
        echo "$bios, not updating."
        ;;
esac
