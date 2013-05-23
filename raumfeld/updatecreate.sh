#!/bin/bash

echo_usage() {
	echo "Usage: $0 --target=<target> --targz=<tar.gz> --kexec=<zimage> --bootloaders=<uboot1.bin,uboot2.bin>"
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

# create a temporary tgz that contains the kexec kernel at the beginning,
# followed by device-tree blobs (optionally), the dts.cramfs (optionally)
# and replacement boot-loaders (optionally).

tmp=$(mktemp).tar
tmpgz=$tmp.gz
gunzip -c $targz > $tmp
tmpdir=$(mktemp -d)
mkdir -p $tmpdir/tmp

cp $kexec $tmpdir/tmp/raumfeld-update.zImage

if [ $target = audioadapter-armada ]; then
    HOSTDIR=$(pwd)/output/host

    # first build the device-tree blobs for direct inclusion
    make HOSTDIR=$HOSTDIR DESTDIR=$tmpdir/tmp/ -C raumfeld/dts

    # work around a bug in the update mechanism in 1.10
    # which looks for the files without the .dtb extension
    cp $tmpdir/tmp/am33xx-raumfeld-connector-0-0.dtb $tmpdir/tmp/am33xx-raumfeld-connector-0-0

    # then a cramfs containing the device-tree blobs
    make host-cramfs
    DIR=$(mktemp -d)
    make HOSTDIR=$HOSTDIR DESTDIR=$DIR/ -C raumfeld/dts
    $HOSTDIR/usr/bin/mkcramfs $DIR $tmpdir/tmp/dts.cramfs
    rm -fr $DIR
fi

for bootloader in $(echo $bootloaders | tr ',' ' '); do
    cp $bootloader $tmpdir/tmp
done

echo "chown -R root.root $tmpdir/tmp" > $tmpdir/.fakeroot
echo "tar -C $tmpdir -f $tmpdir/new.tar -c ./tmp" >> $tmpdir/.fakeroot
chmod a+x $tmpdir/.fakeroot
fakeroot $tmpdir/.fakeroot
tar -f $tmpdir/new.tar -A $tmp
mv $tmpdir/new.tar $tmp
rm -rf $tmpdir
gzip --best $tmp


numfiles=$(tar -f $tmpgz -zt | wc -l)
shasum=$(sha256sum $tmpgz | cut -f1 -d' ')
privatekey=raumfeld/rsa-private.key

# map target name to hardware ID
# keep this in sync with the enum RaumfeldPlatform in libraumfeld
names=( \
    "Unknown"              \
    "Raumfeld Prototype"   \
    "Raumfeld Controller"  \
    "Raumfeld Connector"   \
    "Raumfeld Speaker S"   \
    "Raumfeld Base"        \
    "Raumfeld Speaker M"   \
    "Raumfeld Speaker L"   \
    "Raumfeld One"         \
    "Raumfeld Connector 2" \
    "Raumfeld Cube"        \
    "Raumfeld One 2")

case $target in
	audioadapter-arm)
		hardwareids="3 4 6 7 8"
		;;
	audioadapter-armada)
		hardwareids="9 10 11"
		;;
	remotecontrol-arm)
		hardwareids="2"
		;;
	base-geode)
		hardwareids="5"
		;;
	*)
		echo "Unable to map $target to hardware ID. bummer."
		exit 1
		;;
esac


# only one update per target for the time being

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
