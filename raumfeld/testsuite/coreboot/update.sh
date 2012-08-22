#!/bin/sh

/usr/sbin/flashrom -p internal:laptop=this_is_not_a_laptop,boardmismatch=force -w /raumfeld-base.rom
