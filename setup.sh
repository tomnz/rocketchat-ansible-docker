#!/bin/bash

# Find data drive
DATA_DRIVE=$(sudo lsscsi *:*:*:10 | sed -r 's:[^\]+(\/dev\/[a-z0-9]+).*$:\1:')
DATA_PART="${DATA_DRIVE}1"

# Partition data drive
sudo parted ${DATA_DRIVE} --script mklabel gpt mkpart xfspart xfs 0% 100%
sudo mkfs.xfs ${DATA_PART}
sudo partprobe ${DATA_PART}
# Mount data drive
sudo mkdir /data
sudo mount ${DATA_PART} /data
# Make mount permanent
echo "UUID=`blkid -o value -s UUID ${DATA_PART}`    /data   xfs defaults,nofail 1 2" | sudo tee -a /etc/fstab

# Install prerequisites
sudo apt-get update -y && sudo apt-get install git python3 python3-setuptools python3-pip software-properties-common -y
sudo apt-add-repository -y --update ppa:ansible/ansible
sudo apt-get install ansible -y
pip3 install --upgrade pip setuptools

# Debugging tools (REMOVE?)
sudo apt-get install atop iotop
