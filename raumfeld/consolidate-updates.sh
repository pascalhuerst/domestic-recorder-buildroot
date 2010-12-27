#!/bin/sh

update_ssh="rf-devel.teufel.local:/var/www/devel/updates"

if test -n "${UPDATE_SSH}"; then
  update_ssh=${UPDATE_SSH}
fi

cd raumfeld/updates

rm -fr www
updates=$(find . -type d | tail --lines=+2)

mkdir www

for u in $updates; do
	cp $u/* www/
done

echo "Uploading to $update_ssh"

rsync -ravv -e ssh www/* $update_ssh

count=$(grep version www/*.updates | wc -l)
echo "Consolidation done - $count updates ready"

