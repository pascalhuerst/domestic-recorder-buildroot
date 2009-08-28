#!/bin/sh

update_ssh="user@server.name:/path/to/update/folder"

cd raumfeld/updates

rm -fr www
updates=$(find . -type d | tail -1)

mkdir www

for u in $updates; do
	cat $u/*.description >> www/updates.list
	cp $u/* www/
done

rm -fr www/*.description

# TODO
#rsync -ravv -e ssh www/* $update_ssh

count=$(grep version www/updates.list | wc -l)
echo "Consolidation done - $count updates ready"

