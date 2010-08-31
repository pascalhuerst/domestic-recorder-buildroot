#!/bin/bash

echo_usage() {
	echo "Usage: $0 --target=<target> --targz=<tar.gz> --kexec=<zimage>"
        exit 1
}

. ./getopt.inc
getopt $*

if [ -z "$target" ] || [ -z "$targz" ] || [ -z "$kexec" ]; then
    echo_usage
fi


version=$(tar -f $targz -zx --to-stdout ./etc/raumfeld-version)

if [ -z "$version" ]; then
    echo "Cowardly refusing to build an update without a version."
    exit 1
fi

if [ ! -f "$kexec" ]; then
    echo "Cowardly refusing to build an update without a kexec kernel."
    exit 1
fi

# create a temporary tgz that contains the kexec kernel
tmp=$(mktemp --tmpdir).tar
tmpgz=$tmp.gz
gunzip -c $targz > $tmp
tmpdir=$(mktemp --tmpdir -d)
mkdir -p $tmpdir/tmp
cp $kexec $tmpdir/tmp/raumfeld-update.zImage
echo "chown -R root.root $tmpdir/tmp" > $tmpdir/.fakeroot
echo "cp $kexec ./tmp/raumfeld-update.zImage" >> $tmpdir/.fakeroot
echo "tar -C $tmpdir -f $tmp -r ./tmp/raumfeld-update.zImage" >> $tmpdir/.fakeroot
chmod a+x $tmpdir/.fakeroot
fakeroot $tmpdir/.fakeroot
rm -rf $tmpdir
gzip --best $tmp


numfiles=$(tar -f $tmpgz -zt | wc -l)
shasum=$(sha256sum $tmpgz | cut -f1 -d' ')
privatekey=raumfeld/rsa-private.key

# map target name to hardware ID
# keep this in sync with the enum RaumfeldPlatform in libraumfeld
names=( "Unknown" "Prototype" "Controller" "Connector" "Speaker S" "Base" "Speaker M" )

case $target in
	remotecontrol-arm)
		hardwareids="2"
		;;
	audioadapter-arm)
		hardwareids="3 4 6"
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
    hardwarename=${names[$hardwareid]}
    update_dir=binaries/updates/$hardwareid/
    rm -fr $update_dir
    mkdir -p $update_dir

    cp $tmpgz $update_dir/$shasum
    openssl dgst -sha256 -sign $privatekey \
        -out $update_dir/$shasum.sign $update_dir/$shasum

    cat > $update_dir/$hardwareid.updates << __EOF__
[$shasum]
	description=Software update ($version) for $hardwarename
	num_files=$numfiles
	hardware=$hardwareid
	version=$version

__EOF__
    echo "Update $shasum ($version) created in $update_dir"
done


# remove the temporary targz that we created earlier
rm $tmpgz
