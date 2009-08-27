#!/bin/sh

while (true); do
  remote-control --use-zones > /var/log/remote-control.log 2>&1
  sleep 1
done
