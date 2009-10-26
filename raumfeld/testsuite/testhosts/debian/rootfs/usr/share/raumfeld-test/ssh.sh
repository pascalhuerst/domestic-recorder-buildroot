#!/bin/sh

ssh -i /usr/share/raumfeld-test/key_dsa root@192.168.23.2 'TERM=xterm-color /start-test.sh ssh'

