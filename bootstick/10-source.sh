#!/bin/sh

export PART_BOOT="/dev/sda1"
export PART_ROOT="/dev/sda2"

#
# Create install directories.
#

mkdir -p ~/install ~/mounts ~/mounts/boot ~/mounts/root

#
# Mount partitions.
#

sudo mount $PART_BOOT ~/mounts/boot
sudo mount $PART_ROOT ~/mounts/root

#
# Clean partitions.
#

sudo rm -rf ~/mounts/root/tmp/*
sudo rm -rf ~/mounts/root/var/cache/apt/*

#
# Tar partitions.
#

cd ~/mounts/boot
# shellcheck disable=SC2024
sudo tar -czvpf ../../install/boot.tgz . > ../../install/boot.log 2>&1

cd ~/mounts/root
# shellcheck disable=SC2024
sudo tar --exclude='swapfile' -czvpf ../../install/root.tgz . > ../../install/root.log 2>&1
