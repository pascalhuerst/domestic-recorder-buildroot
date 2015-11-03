#!/bin/bash

set -e

echo_usage() {
    echo "Usage: $0 --output-file=<file> --target=<target> --hardware-ids=<1,2,...> --targz=<tar.gz> --kexec=<zimage> --payload=<uboot1.bin,uboot2.bin> --dts-dir=<dir>"
    exit 1
}

. ./getopt.inc
getopt $*

if [ -z "$output_file" ] || [ -z "$target" ] || [ -z "$hardware_ids" ] || [ -z "$targz" ] || [ -z "$kexec" ]; then
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

check_dts_dir() {
    [[ -d "$dts_dir" ]] || (echo "ERROR: Please pass --dts-dir to point to the directory containing dts.cramfs and dts/*.dtb"; exit 1)
}

case $target in
    audioadapter-armada)
        check_dts_dir
        # first copy all am33xx-raumfeld device-tree blobs for direct inclusion
        cp $dts_dir/dts/am33xx-raumfeld-*.dtb $tmpdir/tmp
        # work around a bug in the update mechanism in 1.10
        # which looks for the files without the .dtb extension
        cp $tmpdir/tmp/am33xx-raumfeld-connector-0-0.dtb $tmpdir/tmp/am33xx-raumfeld-connector-0-0
        # then copy the cramfs containing the device-tree blobs
        cp $dts_dir/dts.cramfs $tmpdir/tmp
        ;;
    base-armada)
        check_dts_dir
        # first copy the am33xx-raumfeld-base device-tree blobs for direct inclusion
        cp $dts_dir/dts/am33xx-raumfeld-base-*.dtb $tmpdir/tmp
        # then copy the cramfs containing the device-tree blobs
        cp $dts_dir/dts.cramfs $tmpdir/tmp
        ;;
esac

for payloaditem in $(echo $payload | tr ',' ' '); do
    cp $payloaditem $tmpdir/tmp
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
    "Unknown"               \
    "Raumfeld Prototype"    \
    "Raumfeld Controller"   \
    "Raumfeld Connector"    \
    "Raumfeld Stereo S"     \
    "Raumfeld Expand"       \
    "Raumfeld Stereo M"     \
    "Raumfeld Stereo L"     \
    "Raumfeld One M"        \
    "Raumfeld Connector 2"  \
    "Raumfeld Stereo Cubes" \
    "Raumfeld One M 2"      \
    "Raumfeld Stereo L 2"   \
    "Raumfeld One S"        \
    "Raumfeld Stereo M 2"   \
    "Raumfeld Expand 2"     \
    "Raumfeld Soundbar"     \
    "Raumfeld Sounddeck")


staging_dir=$(mktemp --directory)

# Create the update image in the staging dir
mv $tmpgz $staging_dir/$shasum
openssl dgst -sha256 -sign $privatekey \
    -out $staging_dir/$shasum.sign $staging_dir/$shasum

# Create a metadata file for each device of this target type
for hardwareid in $(echo $hardwareids | tr , ' '); do
    hardwarename=${names[$hardware_id]}
    cat > $staging_dir/$hardware_id.updates << __EOF__
    [$shasum]
    description=Software update ($version) for $hardwarename
    num_files=$numfiles
    hardware=$hardware_id
    version=$version
__EOF__
done

( cd $staging_dir; tar --create --file=$output_file * )
rm -Rf "$staging_dir"

echo "Update $shasum ($version) created in $output_file"
