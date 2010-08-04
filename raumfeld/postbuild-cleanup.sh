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
rm -f  $1/usr/lib/libvorbisenc*
rm -fr $1/usr/lib/glib-2.0
rm -f  $1/usr/lib/xml2Conf.sh
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
rm -f  $1/usr/share/xml/iso-codes/iso_639.xml
rm -f  $1/usr/share/xml/iso-codes/iso_639_3.xml
rm -f  $1/usr/share/xml/iso-codes/iso_3166_2.xml
rm -f  $1/usr/share/xml/iso-codes/iso_4217.xml
rm -f  $1/usr/share/xml/iso-codes/iso_15924.xml
find $1/usr/share/locale -name iso_639.mo -exec rm -f {} \;
find $1/usr/share/locale -name iso_639_3.mo -exec rm -f {} \;
find $1/usr/share/locale -name iso_3166_2.mo -exec rm -f {} \;
find $1/usr/share/locale -name iso_4217.mo -exec rm -f {} \;
find $1/usr/share/locale -name iso_15924.mo -exec rm -f {} \;
if test -d $1/usr/lib/directfb-1.4-0; then
    find $1/usr/lib/directfb-1.4-0 -name '*.o' -exec rm -f {} \;
fi

if test -n "$TARGET_CROSS"; then
    STRIPCMD=${TARGET_CROSS}strip
    echo "Stripping binaries ..."
    find $1/bin -type f -executable -exec $STRIPCMD {} \;
    find $1/usr/bin -type f -executable -not -name remote-control -exec $STRIPCMD {} \;
    find $1/usr/libexec -type f -executable -exec $STRIPCMD {} \;
    if test -d $1/usr/lib/usr/lib/gstreamer-0.10; then
        find $1/usr/lib/gstreamer-0.10 -type f -executable -exec $STRIPCMD {} \;
    fi
fi
