#!/bin/sh

set -e

vmname=$1
ext2=$2

if [ ! -f "$ext2" ]; then
	echo "Usage: $0 <vm-name> <ext2-image>"
	exit 1
fi

base=$(pwd)/VMs
hdd=${vmname}-hdd.vdi

test -d ${base} || mkdir ${base}

test -f ${base}/${vmname}/${vmname}.vbox && \
	VBoxManage unregistervm --delete ${base}/${vmname}/${vmname}.vbox || true

rm -rf ${base}/${vmname}/${vmname}.vbox

test -f ${hdd} &&
	VBoxManage closemedium disk ${hdd} --delete || true

sudo ./createhdd.sh ${ext2} ${hdd}

VBoxManage createvm 		\
	--name ${vmname}	\
	--basefolder ${base}

VBoxManage registervm ${base}/${vmname}/${vmname}.vbox

VBoxManage modifyvm ${vmname}		\
	--ostype Linux			\
	--memory 512			\
	--acpi on			\
	--cpus 1			\
	--audio null			\
	--audiocontroller ac97		\
	--usb on			\
	--usbehci off			\
	--nic1 intnet			\
	--nictype1 82540EM		\
	--cableconnected1 on		\
	--intnet1 internalether		\
	--nic2 intnet			\
	--nictype2 82540EM		\
	--cableconnected2 on		\
	--intnet2 internalwifi

VBoxManage storagectl ${vmname}	\
	--name hdd		\
	--add ide		\
	--controller PIIX4	\
	--portcount 2		\
	--hostiocache on	\
	--bootable on

VBoxManage storageattach ${vmname}	\
	--storagectl hdd		\
	--port 0			\
	--device 0			\
	--type hdd			\
	--medium ${hdd}	

