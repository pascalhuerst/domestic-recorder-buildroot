#!/bin/sh
#
# post-build cleanup for the target rootfs

rm -fr $1/usr/include
rm -fr $1/usr/lib/pkg-config
rm -f  $1/usr/lib/*.la
rm -fr $1/usr/lib/libarchive*
rm -fr $1/usr/lib/glib-2.0
rm -f  $1/usr/libexec/gvfsd-archive
rm -f  $1/usr/libexec/gvfsd-burn
rm -f  $1/usr/libexec/gvfsd-trash
rm -fr $1/usr/share/aclocal
rm -fr $1/usr/share/gdb
rm -fr $1/usr/share/glib-2.0
