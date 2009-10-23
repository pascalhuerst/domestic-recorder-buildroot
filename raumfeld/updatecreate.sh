#!/bin/bash

echo_usage() {
	echo "Usage: $0 --target=<target> --targz=<tar.gz>"
        exit 1
}

. ./getopt.inc
getopt $*

if [ -z "$target" ] || [ -z "$targz" ]; then
    echo_usage
fi


version=$(tar -f $targz -zx --to-stdout ./etc/raumfeld-version)

if [ -z "$version" ]; then
    echo "Cowardly refusing to build an update without a version."
    exit 1
fi

numfiles=$(tar -f $targz -zt | wc -l)
shasum=$(sha256sum $targz | cut -f1 -d' ')
privatekey=raumfeld/rsa-private.key

# map target name to hardware ID
# keep this in sync with the enum in libraumfeld!

case $target in
	remotecontrol-arm)
		hardwareids="2"
		;;
	audioadapter-arm)
		hardwareids="3 4"
		;;
	base-geode)
		hardwareids="5"
		;;
	*)
		echo "Unable to map $target to hardware ID. bummer."
		exit 1
		;;
esac

# only one update per target for the time being.

for hardwareid in $hardwareids; do
    update_dir=binaries/updates/$hardwareid/
    rm -fr $update_dir
    mkdir -p $update_dir

    cp $targz $update_dir/$shasum
    openssl dgst -sha256 -sign $privatekey \
        -out $update_dir/$shasum.sign $update_dir/$shasum

    cat > $update_dir/$hardwareid.updates << __EOF__
[$shasum]
	description=Software update ($version) for $target
	num_files=$numfiles
	hardware=$hardwareid
	version=$version

__EOF__
    echo "Update $shasum ($version) created in $update_dir"
done

