#!/bin/sh
#
# post-build.sh for the base-geode target

echo "Populating the root filesystem ..."
rm -f $1/etc/resolv.conf
cp -r raumfeld/rootfs-geode/* $1

mkdir -p $1/Music/Music

cat << __EOF__ > $1/etc/fstab
# /etc/fstab: static file system information.
#
# <file system>	<mount pt>	<type>	<options>	<dump>	<pass>
/dev/root	/		ext3	rw,noauto	0	1
proc		/proc		proc	defaults	0	0
devpts		/dev/pts	devpts	defaults,gid=5,mode=620	0	0
tmpfs		/tmp		tmpfs	defaults	0	0
sysfs		/sys		sysfs	defaults	0	0

/dev/hda1	/boot		ext3	rw		0	0
/dev/hda3	/Music/Music	ext3	rw		0	0

__EOF__


raumfeld/postbuild-cleanup.sh $1
