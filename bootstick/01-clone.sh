#!/bin/sh

export DISK_SOURCE="/dev/sda"
export DISK_TARGET="/dev/sdx"

#
# Copy master boot record.
#

sudo dd if=$DISK_SOURCE of=$DISK_TARGET bs=446 count=1

#
# Clone and randomize partition map.
#
sudo sgdisk -R=$DISK_TARGET $DISK_SOURCE
sudo sgdisk -G $DISK_TARGET

#
# Copy EFI partition.
#
sudo dd if=${DISK_SOURCE}1 of=${DISK_TARGET}1 bs=1M status=progress
sudo fsck -p ${DISK_TARGET}1

#
# Copy Linux partition.
#
sudo dd if=${DISK_SOURCE}2 of=${DISK_TARGET}2 bs=1M status=progress
sudo fsck -p ${DISK_TARGET}2
