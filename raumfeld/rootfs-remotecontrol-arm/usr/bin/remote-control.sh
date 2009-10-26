#!/bin/sh

export RAUMFELD_UPDATES_URL=http://devel.internal/updates/

while (true); do
  remote-control > /var/log/remote-control.log 2>&1
  sleep 1
done
