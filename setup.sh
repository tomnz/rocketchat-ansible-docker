#!/bin/bash

# Note: This script is designed to be run on a fresh Azure VM after initial configuration.
# Assumes the presence of an empty data drive with LUN=10, which will be mounted to /data.

# Exit on error
set -e

if [ ! -d "/data" ]
then
	# Find data drive
	DATA_DRIVE=$(sudo lsscsi *:*:*:10 | sed -r 's:[^\]+(\/dev\/[a-z0-9]+).*$:\1:')
	if [ -z "$DATA_DRIVE" ]
	then
		echo "No data drive found! Must be created with LUN=10"
		exit 1
	fi
	DATA_PART="${DATA_DRIVE}1"

	# Partition data drive
	parted ${DATA_DRIVE} --script mklabel gpt mkpart xfspart xfs 0% 100%
	mkfs.xfs ${DATA_PART}
	partprobe ${DATA_PART}
	# Mount data drive
	mkdir /data
	mount ${DATA_PART} /data
	# Make mount permanent
	echo "UUID=`blkid -o value -s UUID ${DATA_PART}`	/data	xfs	defaults,nofail	1	2" | tee -a /etc/fstab
fi

if [ ! -d "/backup" ]
then
	# Find data drive
	BACKUP_DRIVE=$(sudo lsscsi *:*:*:11 | sed -r 's:[^\]+(\/dev\/[a-z0-9]+).*$:\1:')
	if [ -z "$BACKUP_DRIVE" ]
	then
		echo "No backup drive found! Must be created with LUN=11"
		exit 1
	fi
	BACKUP_PART="${BACKUP_DRIVE}1"

	# Partition data drive
	parted ${BACKUP_DRIVE} --script mklabel gpt mkpart xfspart xfs 0% 100%
	mkfs.xfs ${BACKUP_PART}
	partprobe ${BACKUP_PART}
	# Mount data drive
	mkdir /backup
	mount ${BACKUP_PART} /backup
	# Make mount permanent
	echo "UUID=`blkid -o value -s UUID ${BACKUP_PART}`	/backup	xfs	defaults,nofail	1	2" | tee -a /etc/fstab
fi

# Install prerequisites
apt-get update -y && sudo apt-get install -y git python3 python3-setuptools python3-pip software-properties-common
apt-add-repository -y --update ppa:ansible/ansible
apt-get install -y ansible
pip3 install --upgrade pip setuptools

# Debugging tools (REMOVE?)
apt-get install -y atop sysstat
