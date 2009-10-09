#!/bin/sh

while (true); do
  remote-control > /var/log/remote-control.log 2>&1
  sleep 1
done
