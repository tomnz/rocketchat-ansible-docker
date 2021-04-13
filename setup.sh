#!/bin/bash

# Note: This script is designed to be run on a fresh Azure VM after initial configuration.
# Assumes the presence of an empty data drive with LUN=10, which will be mounted to /data.

# Exit on error
set -e

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

# Install prerequisites
apt-get update -y && sudo apt-get install git python3 python3-setuptools python3-pip software-properties-common -y
apt-add-repository -y --update ppa:ansible/ansible
apt-get install ansible -y
pip3 install --upgrade pip setuptools

# Debugging tools (REMOVE?)
apt-get install atop sysstat
