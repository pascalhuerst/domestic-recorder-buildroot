#!/bin/sh
#
# post-build cleanup for the initramfs

echo "Purging unwanted files ..."

rm -fr $1/home
rm -fr $1/lib/modules
