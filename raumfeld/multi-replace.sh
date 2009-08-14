#!/bin/sh

search=$1
replace=$2

([ -z "$search" ] || [ -z "$replace" ]) && (echo "Usage: $0 <search> <replace> <file> [<file>, ...]"; exit 1)

shift; shift;

for x in $*; do
	sed -i'' -e 's/'$search'/'$replace'/g' $x
done

