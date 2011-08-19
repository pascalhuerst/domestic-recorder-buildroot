#!/bin/sh
#
# post-build cleanup for the target rootfs

echo "Creating default files"
test -d $1/etc/raumfeld/ || mkdir $1/etc/raumfeld/

echo "Purging unwanted files ..."

rm -fr $1/etc/bash_completion.d
rm -fr $1/etc/usbmount/usbmount.d
rm -fr $1/home
rm -f  $1/lib/udev/accelerometer
rm -f  $1/lib/udev/keymap
rm -fr $1/lib/udev/keymaps
rm -f  $1/lib/udev/cdrom_id
rm -f  $1/lib/udev/v4l_id
rm -f  $1/lib/udev/rules.d/42-qemu-usb.rules
rm -f  $1/lib/udev/rules.d/60-cdrom_id.rules
rm -f  $1/lib/udev/rules.d/60-persistent-v4l.rules
rm -f  $1/lib/udev/rules.d/61-accelerometer.rules
rm -f  $1/lib/udev/rules.d/75-cd-aliases-generator.rules
rm -f  $1/lib/udev/rules.d/95-keyboard-force-release.rules
rm -f  $1/lib/udev/rules.d/95-keymap.rules
rm -fr $1/usr/include
rm -f  $1/usr/bin/arm-linux-directfb-csource
rm -f  $1/usr/bin/certtool
rm -f  $1/usr/bin/dbus-binding-tool
rm -f  $1/usr/bin/directfb-config
rm -f  $1/usr/bin/faad
rm -f  $1/usr/bin/flac
rm -f  $1/usr/bin/gdbus
rm -f  $1/usr/bin/glib-compile-schemas
rm -f  $1/usr/bin/glib-genmarshal
rm -f  $1/usr/bin/glib-gettextize
rm -f  $1/usr/bin/glib-mkenums
rm -f  $1/usr/bin/gobject-query
rm -f  $1/usr/bin/gnutls-*
rm -f  $1/usr/bin/gsettings
rm -f  $1/usr/bin/gst-feedback
rm -f  $1/usr/bin/gst-inspect
rm -f  $1/usr/bin/gst-launch
rm -f  $1/usr/bin/gst-typefind
rm -f  $1/usr/bin/gst-visualise-0.10
rm -f  $1/usr/bin/gst-xmlinspect
rm -f  $1/usr/bin/gst-xmlinspect-0.10
rm -f  $1/usr/bin/gtester
rm -f  $1/usr/bin/gtester-report
rm -f  $1/usr/bin/gupnp-binding-tool
rm -f  $1/usr/bin/gvfs-trash
rm -f  $1/usr/bin/iconv
rm -f  $1/usr/bin/jpegtran
rm -f  $1/usr/bin/mail-lock
rm -f  $1/usr/bin/mail-touchlock
rm -f  $1/usr/bin/mail-unlock
rm -f  $1/usr/bin/metaflac
rm -f  $1/usr/bin/nettle-lfib-stream
rm -f  $1/usr/bin/orcc
rm -f  $1/usr/bin/orc-bugreport
rm -f  $1/usr/bin/p11tool
rm -f  $1/usr/bin/pkcs1-conv
rm -f  $1/usr/bin/psktool
rm -f  $1/usr/bin/sexp-conv
rm -f  $1/usr/bin/srptool
rm -f  $1/usr/bin/ssh-keyscan
rm -f  $1/usr/bin/xml2-config
rm -f  $1/usr/bin/xmlcatalog
rm -f  $1/usr/bin/xmllint
rm -fr $1/usr/lib/pkg-config
rm -f  $1/usr/lib/*.la
rm -f  $1/usr/lib/libvorbisenc*
rm -fr $1/usr/lib/glib-2.0
rm -f  $1/usr/lib/ssh-keysign
rm -f  $1/usr/lib/ssh-pkcs11-helper
rm -f  $1/usr/lib/xml2Conf.sh
rm -f  $1/usr/libexec/gvfsd-archive
rm -f  $1/usr/libexec/gvfsd-burn
rm -f  $1/usr/libexec/gvfsd-computer
rm -f  $1/usr/libexec/gvfsd-localtest
rm -f  $1/usr/libexec/gvfsd-trash
rm -fr $1/usr/share/aclocal
rm -fr $1/usr/share/alsa/cards
rm -fr $1/usr/share/alsa/pcm
rm -fr $1/usr/share/applications
rm -fr $1/usr/share/avahi/introspection
rm -fr $1/usr/share/common-lisp
rm -fr $1/usr/share/gdb
rm -f  $1/usr/share/getopt/*.tcsh
rm -fr $1/usr/share/gvfs/remote-volume-monitors
rm -fr $1/usr/share/pkgconfig
rm -fr $1/usr/share/sounds
rm -f  $1/usr/share/xml/iso-codes/iso_639.xml
rm -f  $1/usr/share/xml/iso-codes/iso_639_3.xml
rm -f  $1/usr/share/xml/iso-codes/iso_3166_2.xml
rm -f  $1/usr/share/xml/iso-codes/iso_4217.xml
rm -f  $1/usr/share/xml/iso-codes/iso_15924.xml
find $1/usr/share/locale -name e2fsprogs.mo -exec rm -f {} \;
find $1/usr/share/locale -name iso_639.mo -exec rm -f {} \;
find $1/usr/share/locale -name iso_639_3.mo -exec rm -f {} \;
find $1/usr/share/locale -name iso_3166_2.mo -exec rm -f {} \;
find $1/usr/share/locale -name iso_4217.mo -exec rm -f {} \;
find $1/usr/share/locale -name iso_15924.mo -exec rm -f {} \;
if test -d $1/usr/lib/directfb-1.4-5; then
    find $1/usr/lib/directfb-1.4-5 -name '*.o' -exec rm -f {} \;
    rm -fr $1/usr/lib/directfb-1.4-5/interfaces/IDirectFBVideoProvider
    rm -f $1/usr/lib/directfb-1.4-5/interfaces/IDirectFBImageProvider/libidirectfbimageprovider_dfiff.so
    rm -f $1/usr/lib/directfb-1.4-5/interfaces/IDirectFBFont/libidirectfbfont_dgiff.so
fi
