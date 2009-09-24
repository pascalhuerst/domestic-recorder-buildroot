#!/bin/sh

update_ssh="devel.internal:/var/www/devel/updates"

cd raumfeld/updates

rm -fr www
updates=$(find . -type d | tail --lines=+2)

mkdir www

for u in $updates; do
	cp $u/* www/
done

rsync -ravv -e ssh www/* $update_ssh

count=$(grep version www/*.updates | wc -l)
echo "Consolidation done - $count updates ready"

