#!/bin/sh

#
# Tar the box master drives
# to usb master stick.
#

export PART_BOOT="/dev/sda1"
export PART_ROOT="/dev/sda2"

#
# Create install directories.
#

mkdir -p ~/install ~/mounts ~/mounts/boot ~/mounts/root

#
# Remount partitions.
#

sudo umount $PART_BOOT
sudo umount $PART_ROOT

sudo mount $PART_BOOT ~/mounts/boot
sudo mount $PART_ROOT ~/mounts/root

#
# Clean partitions.
#

sudo rm -rf ~/mounts/root/tmp/*
sudo rm -rf ~/mounts/root/var/cache/apt/*
sudo rm -rf ~/mounts/root/opt/box/log/*
sudo rm -rf ~/mounts/root/opt/box/var/ipfs
sudo rm -rf ~/mounts/root/opt/box/var/backups
sudo rm -rf ~/mounts/root/home/liesa/dezibox
sudo rm -rf ~/mounts/root/home/liesa/.android

sudo rm -rf ~/mounts/root/var/lib/bluetooth
sudo mkdir ~/mounts/root/var/lib/bluetooth
sudo rm -rf ~/mounts/root/etc/NetworkManager/system-connections
sudo mkdir ~/mounts/root/etc/NetworkManager/system-connections

#
# Tar partitions.
#

cd ~/mounts/boot
# shellcheck disable=SC2024
sudo tar -czvpf ../../install/boot.tgz . > ../../install/boot.log 2>&1

cd ~/mounts/root
# shellcheck disable=SC2024
sudo tar --exclude='swapfile' -czvpf ../../install/root.tgz . > ../../install/root.log 2>&1

#sudo umount ~/mounts/boot
#sudo umount ~/mounts/root

echo "Box copy done..."
