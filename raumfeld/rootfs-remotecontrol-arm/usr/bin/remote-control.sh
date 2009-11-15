#!/bin/sh

while (true); do

    echo "creating pipe"
    mknod /tmp/remote-control-logger-pipe pipe

    echo "starting logger"
    logger -t "remote-control" < /tmp/remote-control-logger-pipe &

    echo "starting remote-control"
    remote-control > /tmp/remote-control-logger-pipe 2>&1
    
    echo "remote-control exited"

    sleep 1

done
