#!/bin/sh

SSH_COOKIE="/etc/raumfeld/sshd_enabled"

log()
{
    echo "enable-rootkit --> $1" | logger
}


if [ -f $SSH_COOKIE ]; then
    log "the ssh cookie already exists, nothing to be done"
    exit
fi


log "try to enable the rootkit"

MOUNT_POINT="/media/rootkit-test"

log "creating mount point $MOUNT_POINT"

mkdir -p $MOUNT_POINT

log "starting usbmount add"

export MOUNTPOINTS=$MOUNT_POINT
export VERBOSE=y

/sbin/usbmount add

sshenable=48fab7623bce0c903d5fe53dd681bb163eba85ae
secret=$MOUNT_POINT/$sshenable

log "trying to find the secret"

if [ -f $secret ]; then 
    log "found the secret $secret"

    if [ -f $SSH_COOKIE ]; then
	log "the ssh cookie already exists"
    else
	log "the cookie has to be created"
	touch $SSH_COOKIE
	/etc/init.d/S50sshd start
    fi
else
    log "did not find the secret $secret"
fi

log "starting usbmount remove"

/sbin/usbmount remove

log "removing the mount point"

rmdir $MOUNT_POINT