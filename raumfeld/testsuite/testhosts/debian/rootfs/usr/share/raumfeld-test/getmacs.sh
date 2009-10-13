#!/bin/sh

nmacs=100
list=/var/raumfeld-test/macaddr.list
tmp=/tmp/getmacs.tmp
# 00:26:06 -> 9734
pool=9734
server=http://buildcontrol.caiaq.de/macaddr.php

curr=$(cat $list | wc -l)
get=$(($nmacs - $curr))

wget --timeout=10 --tries=1 "$server?machine=$host&pool=$pool&num=$get" -O $tmp
cat $tmp >> $list
rm -f $tmp

count=$(wc -l $list | cut -f1 -d ' ')

test "$count" -lt "$nmacs" && exit 1

echo counted $count
