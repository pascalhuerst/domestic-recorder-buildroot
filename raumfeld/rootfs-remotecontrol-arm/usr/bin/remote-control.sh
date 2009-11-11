#!/bin/sh

export RAUMFELD_UPDATES_URL=http://devel.internal/updates/

while (true); do

    echo "creating pipe"
    mknod /tmp/master-process-logger-pipe pipe

    echo "starting logger"
    logger -t "remote-control" < /tmp/master-process-logger-pipe &

    echo "starting remote-control"
    remote-control > /tmp/master-process-logger-pipe 2>&1
    
    echo "remote-control exited"

    sleep 1

done
