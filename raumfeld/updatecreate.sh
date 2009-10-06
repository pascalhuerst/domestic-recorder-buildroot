#!/bin/bash

echo_usage() {
	echo "Usage: $0 --target=<target> --targz=<tar.gz>"
        exit 1
}

. ./getopt.inc
getopt $*

if [ -z "$target" ] || [ -z "$targz" ];
then echo_usage; fi

numfiles=$(tar -f $targz -zt | wc -l)
git_version=$(git describe --tags)
version=${git_version#raumfeld-}
buildnumber=$(cat build_number)
shasum=$(sha256sum $targz | cut -f1 -d' ')
privatekey=raumfeld/rsa-private.key
update_dir=raumfeld/updates/$target/

# map target name to hardware ID
# keep this in sync with the enum in libraumfeld!

case $target in
	remotecontrol-arm)
		hardwareid=2
		;;
	audioadapter-arm)
		hardwareid=3
		;;
	*)
		echo "unable to map $target to hardware ID. bummer."
		exit 1
		;;
esac

# only one update per target for the time being.

rm -fr $update_dir
mkdir -p $update_dir

cp $targz $update_dir/$shasum
openssl dgst -sha256 -sign $privatekey -out $update_dir/$shasum.sign $update_dir/$shasum

cat > $update_dir/$hardwareid.updates << __EOF__
[$shasum]
	description=Software update ($version) for $target
	num_files=$numfiles
	hardware=$hardwareid
	version=$buildnumber

__EOF__

echo "update $shasum created in $update_dir"

