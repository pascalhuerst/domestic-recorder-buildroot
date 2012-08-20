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

revision=$(dmidecode -t bios | grep BIOS\ Revision)

# with the old BIOS, dmidecode is not able to get the revision

if [ -z $revision ]; then
    echo "Updating the BIOS, cross your fingers ..."
    flashrom -p internal:laptop=this_is_not_a_laptop -w /raumfeld-base.rom
else
    echo "$revision, not updating."
    exit 0
fi
