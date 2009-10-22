#!/bin/bash

echo_usage() {
	echo "Usage: $0 --target=<target> --targz=<tar.gz> --version=<version>"
        exit 1
}

. ./getopt.inc
getopt $*

if [ -z "$target" ] || [ -z "$targz" ] || [ -z "$version" ]; then
    echo_usage
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
		echo "unable to map $target to hardware ID. bummer."
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
    echo "update $shasum created in $update_dir"
done

