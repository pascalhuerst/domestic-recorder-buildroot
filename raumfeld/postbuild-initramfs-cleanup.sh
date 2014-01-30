#!/bin/sh
#
# post-build cleanup for the initramfs

echo "Purging unwanted files ..."

rm -fr $1/lib/modules
rm -fr $1/usr/share/bash-completion
