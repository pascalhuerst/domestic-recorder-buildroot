#!/bin/sh

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 configfile1 configfile2" >&2
  exit 1
fi

grep -vE '^([ \t]*#|^[ \t]*$)' $1 > f1.tmp
grep -vE '^([ \t]*#|^[ \t]*$)' $2 > f2.tmp

diff -b f1.tmp f2.tmp || (rm f1.tmp; rm f2.tmp)

exit 0
