#!/bin/sh

rm -fr root
mkdir root
mkdir -p root/DEBIAN/
cp control root/DEBIAN/
cp postinst root/DEBIAN/

cp -a rootfs/* root/
chmod 0600 root/usr/share/raumfeld-test/key_dsa*

# FIXME!

chown daniel root/usr/share/raumfeld-test/key_dsa*

find root/ -type d -name \.svn | xargs -r rm -fr
dpkg-deb --build root/ .

rm -fr root

