#!/bin/sh
#
# post-build cleanup for the target rootfs

echo "Creating default files"
test -d $1/etc/raumfeld/ || mkdir $1/etc/raumfeld/

echo "Purging unwanted files ..."

rm -fr $1/usr/include
rm -f  $1/usr/bin/dbus-binding-tool
rm -f  $1/usr/bin/faad
rm -f  $1/usr/bin/flac
rm -f  $1/usr/bin/glib-genmarshal
rm -f  $1/usr/bin/glib-gettextize
rm -f  $1/usr/bin/glib-mkenums
rm -f  $1/usr/bin/gobject-query
rm -f  $1/usr/bin/gst-visualise-0.10
rm -f  $1/usr/bin/gtester
rm -f  $1/usr/bin/gtester-report
rm -f  $1/usr/bin/gupnp-binding-tool
rm -f  $1/usr/bin/iconv
rm -f  $1/usr/bin/metaflac
rm -f  $1/usr/bin/ssh-keyscan
rm -f  $1/usr/bin/xml2-config
rm -f  $1/usr/bin/xmlcatalog
rm -f  $1/usr/bin/xmllint
rm -fr $1/usr/lib/pkg-config
rm -f  $1/usr/lib/*.la
rm -f  $1/usr/lib/libarchive*
rm -f  $1/usr/lib/libvorbisenc*
rm -fr $1/usr/lib/glib-2.0
rm -f  $1/usr/libexec/gvfsd-archive
rm -f  $1/usr/libexec/gvfsd-burn
rm -f  $1/usr/libexec/gvfsd-trash
rm -fr $1/usr/share/aclocal
rm -f  $1/usr/share/alsa/cards/[A-Z]*.conf
rm -f  $1/usr/share/alsa/pcm/center_lfe.conf
rm -f  $1/usr/share/alsa/pcm/dpl.conf
rm -f  $1/usr/share/alsa/pcm/front.conf
rm -f  $1/usr/share/alsa/pcm/hdmi.conf
rm -f  $1/usr/share/alsa/pcm/iec958.conf
rm -f  $1/usr/share/alsa/pcm/modem.conf
rm -f  $1/usr/share/alsa/pcm/rear.conf
rm -f  $1/usr/share/alsa/pcm/side.conf
rm -f  $1/usr/share/alsa/pcm/surround*.conf
rm -rf $1/usr/share/avahi/introspection
rm -fr $1/usr/share/gdb
rm -fr $1/usr/share/glib-2.0

