#!/bin/sh

echo "starting gvfsd"
# export GVFS_SMB_DEBUG=3
# export GVFS_DEBUG=1
eval `dbus-launch --sh-syntax`
/usr/libexec/gvfsd &

while (true); do

    echo "creating pipe"
    mknod /tmp/remote-control-logger-pipe pipe

    echo "starting logger"
    logger -t "remote-control" < /tmp/remote-control-logger-pipe &

    echo "starting remote-control"
    remote-control > /tmp/remote-control-logger-pipe 2>&1
    
    echo "remote-control exited"

    sleep 2

done
