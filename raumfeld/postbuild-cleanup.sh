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
rm -f  $1/lib/udev/rules.d/60-persistent-storage-tape.rules
rm -f  $1/lib/udev/rules.d/60-persistent-v4l.rules
rm -f  $1/lib/udev/rules.d/61-accelerometer.rules
rm -f  $1/lib/udev/rules.d/78-sound-card.rules
rm -fr $1/media/usb*
rm -fr $1/usr/include
rm -f  $1/usr/bin/arm-linux-directfb-csource
rm -f  $1/usr/bin/certtool
rm -f  $1/usr/bin/dbus-binding-tool
rm -f  $1/usr/bin/directfb-config
rm -f  $1/usr/bin/dumpsexp
rm -f  $1/usr/bin/faad
rm -f  $1/usr/bin/flac
rm -f  $1/usr/bin/gdbus
rm -f  $1/usr/bin/gdbus-codegen
rm -f  $1/usr/bin/glib-compile-resources
rm -f  $1/usr/bin/glib-compile-schemas
rm -f  $1/usr/bin/glib-genmarshal
rm -f  $1/usr/bin/glib-gettextize
rm -f  $1/usr/bin/glib-mkenums
rm -f  $1/usr/bin/gnutls-*
rm -f  $1/usr/bin/gobject-query
rm -f  $1/usr/bin/gpg-error
rm -f  $1/usr/bin/gpg-error-config
rm -f  $1/usr/bin/gresource
rm -f  $1/usr/bin/gsettings
rm -f  $1/usr/bin/gst-discoverer-1.0
rm -f  $1/usr/bin/gst-inspect-1.0
rm -f  $1/usr/bin/gst-play-1.0
rm -f  $1/usr/bin/gst-typefind-1.0
rm -f  $1/usr/bin/gtester
rm -f  $1/usr/bin/gtester-report
rm -f  $1/usr/bin/gupnp-binding-tool
rm -f  $1/usr/bin/gvfs-trash
rm -f  $1/usr/bin/iconv
rm -f  $1/usr/bin/libgcrypt-config
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
rm -fr $1/usr/lib/gdbus-2.0
rm -fr $1/usr/lib/glib-2.0
rm -f  $1/usr/lib/gstreamer-1.0/libgstavscale.so
rm -f  $1/usr/lib/libgstallocators-1.0.so*
rm -f  $1/usr/lib/libgstapp-1.0.so*
rm -f  $1/usr/lib/libgstbasecamerabinsrc-1.0.so*
rm -f  $1/usr/lib/libgstcodecparsers-1.0.so*
rm -f  $1/usr/lib/libgstcontroller-1.0.so*
rm -f  $1/usr/lib/libgstfft-1.0.so*
rm -f  $1/usr/lib/libgstinsertbin-1.0.so*
rm -f  $1/usr/lib/libgstmpegts-1.0.so*
rm -f  $1/usr/lib/libgstnet-1.0.so*
rm -f  $1/usr/lib/libgstphotography-1.0.so*
rm -f  $1/usr/lib/libgsturidownloader-1.0.so*
rm -f  $1/usr/lib/libvorbisenc*
rm -f  $1/usr/lib/ssh-keysign
rm -f  $1/usr/lib/ssh-pkcs11-helper
rm -f  $1/usr/lib/xml2Conf.sh
rm -f  $1/usr/libexec/gvfsd-archive
rm -f  $1/usr/libexec/gvfsd-burn
rm -f  $1/usr/libexec/gvfsd-computer
rm -f  $1/usr/libexec/gvfsd-ftp
rm -f  $1/usr/libexec/gvfsd-http
rm -f  $1/usr/libexec/gvfsd-localtest
rm -f  $1/usr/libexec/gvfsd-sftp
rm -f  $1/usr/libexec/gvfsd-trash
rm -fr $1/usr/share/GConf
rm -fr $1/usr/share/aclocal
rm -fr $1/usr/share/bash-completion
rm -fr $1/usr/share/alsa/cards
rm -fr $1/usr/share/alsa/pcm
rm -fr $1/usr/share/applications
rm -fr $1/usr/share/avahi/introspection
rm -fr $1/usr/share/common-lisp
rm -fr $1/usr/share/gdb
rm -f  $1/usr/share/getopt/*.tcsh
rm -fr $1/usr/share/glib-2.0/codegen
rm -fr $1/usr/share/gst-plugins-base/1.0
rm -f  $1/usr/share/gvfs/mounts/burn.mount
rm -f  $1/usr/share/gvfs/mounts/computer.mount
rm -f  $1/usr/share/gvfs/mounts/ftp.mount
rm -f  $1/usr/share/gvfs/mounts/http.mount
rm -f  $1/usr/share/gvfs/mounts/localtest.mount
rm -f  $1/usr/share/gvfs/mounts/sftp.mount
rm -f  $1/usr/share/gvfs/mounts/trash.mount
rm -fr $1/usr/share/pkgconfig
rm -fr $1/usr/share/sounds
find $1/usr/share/locale -name e2fsprogs.mo -exec rm -f {} \;
if test -d $1/usr/lib/directfb-1.4-6; then
    find $1/usr/lib/directfb-1.4-6 -name '*.o' -exec rm -f {} \;
    rm -fr $1/usr/lib/directfb-1.4-6/interfaces/IDirectFBVideoProvider
    rm -f  $1/usr/lib/directfb-1.4-6/interfaces/IDirectFBImageProvider/libidirectfbimageprovider_dfiff.so
    rm -f  $1/usr/lib/directfb-1.4-6/interfaces/IDirectFBFont/libidirectfbfont_dgiff.so
    rm -f  $i/usr/lib/directfb-1.4-6/interfaces/ICoreResourceManager/libicoreresourcemanager_test.so
fi
rm -fr $1/var/www
