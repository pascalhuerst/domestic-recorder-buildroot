#!/usr/bin/env bash

if test "$#" -ne 2; then
    echo "Usage $0 host token" 1>&2
    echo "host must be ssh enabled" 1>&2
    exit 1
fi

host=$1
token=$2
checkHostKey=''
#-o StrictHostKeyChecking=no

if ping -c 1 $host &> /dev/null; then
    status=$(ssh -o BatchMode=yes -o ConnectTimeout=5 root@$host echo ok 2>&1)

    if [[ $status == ok ]] ; then
        #prepare some stuff on target host
        ssh $checkHostKey root@$host touch /etc/NOTICE.html.gz
        ssh $checkHostKey root@$host mkdir -p /system/usr/share/fonts
        ssh $checkHostKey root@$host ln -fs /system/usr/share/fonts /usr/share/fonts
        ssh $checkHostKey root@$host mkdir -p /install
        ssh $checkHostKey root@$host echo $token \> /etc/raumfeld/gc4a_token

        #prepare some stuff on target host
        #rsync -az  ./streamcastdaemon root@$host:/ ### unfortunatley no rsync on target, let's recopy all
        #scp $checkHostKey -qr ./streamcastdaemon/* root@$host:/
        echo "copy streamcast daemon package"
	scp streamcastdaemon-package-v1.0.tar root@$host:/
        echo "copy preliminary scripts"
        scp $checkHostKey -qr ./install/* root@$host:/install/
        echo "run setup (you might see file exists errors)"
        ssh $checkHostKey root@$host /install/setup.sh

    elif [[ $status == "Permission denied"* ]] ; then
        echo no_auth
    else
        echo other_error, maybe try ssh-keygen -R $host
    fi
else
  echo "host $host is not reachable" 1>&2
  exit 1 
fi

