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

case "x$revision" in
    x|'xBIOS Revision 3.0')
        echo $revision
        echo "Updating the BIOS, cross your fingers ..."
        flashrom -p internal:laptop=this_is_not_a_laptop,boardmismatch=force -w raumfeld-base.rom
        ;;
    *)
        echo "$revision, not updating."
        ;;
esac
