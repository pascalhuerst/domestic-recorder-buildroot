#!/bin/sh

set -e

# obtain new build number
PROJECT_NAME=raumfeld-build-all
USER=$(whoami)
wget -q -O- "http://buildcontrol.caiaq.de/new.php?mode=dump&project=$PROJECT_NAME&username=$USER" > build_number

git_version=$(git describe --tags --abbrev=0)
version=${git_version#raumfeld-}
buildnumber=$(cat build_number)
versionstr="$version.$buildnumber"

./buildlog.sh $0: versionstr=$versionstr

echo $versionstr > raumfeld/rootfs-audioadapter-arm/etc/raumfeld-version
echo $versionstr > raumfeld/rootfs-remotecontrol-arm/etc/raumfeld-version

# initramfs and imgrootfs is needed to build before the other targets,
# so build them first
./build.sh --target=initramfs-arm
./build.sh --target=imgrootfs-arm

./build.sh --target=initramfs-geode
./build.sh --target=imgrootfs-geode

./build.sh --target=audioadapter-arm
./build.sh --target=remotecontrol-arm

./build.sh --target=base-geode
# add others here ...


# this puts together all created updates and copies them to the update server
# raumfeld/consolidate-updates.sh

