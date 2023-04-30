#!/bin/sh

sudo apt -y install mtools

export DISK_SOURCE="/dev/sdb"
export DISK_TARGET="/dev/sdc"

# shellcheck disable=SC2155
export NEW_EXT4_UUID=$(uuidgen)
# shellcheck disable=SC2039
export NEW_VFAT_DOSID=${NEW_EXT4_UUID:0:8}
# shellcheck disable=SC2039
export NEW_VFAT_UUID=${NEW_VFAT_DOSID:0:4}-${NEW_VFAT_DOSID:4:4}
# shellcheck disable=SC2039
export NEW_VFAT_UUID=${NEW_VFAT_UUID^^}

export MOUNT=~/mounts
export MOUNT_BOOT=${MOUNT}/${NEW_VFAT_UUID}_boot
export MOUNT_ROOT=${MOUNT}/${NEW_EXT4_UUID}_root

#
# Preprocessing.
#

mkdir -p $MOUNT $MOUNT_BOOT $MOUNT_ROOT

#
# Copy master boot record.
#

sudo dd if=$DISK_SOURCE of=$DISK_TARGET bs=446 count=1

#
# Clone and randomize partition map.
#
sudo sgdisk --replicate=$DISK_TARGET $DISK_SOURCE
sudo sgdisk --randomize-guids $DISK_TARGET

#
# Copy EFI partition, fsck and change UUID.
#
sudo dd if=${DISK_SOURCE}1 of=${DISK_TARGET}1 bs=1M status=progress
sudo fsck -p ${DISK_SOURCE}1
sudo mlabel -i ${DISK_TARGET}1 -N $NEW_VFAT_DOSID

#
# Copy Linux partition, fsck and change UUID.
#
sudo dd if=${DISK_SOURCE}2 of=${DISK_TARGET}2 bs=1M status=progress
sudo e2fsck -y -f ${DISK_TARGET}2
sudo tune2fs ${DISK_TARGET}2 -U $NEW_EXT4_UUID

#
# Adjust /boot/EFI/ubuntu/grub.cfg  for new UUIDs.
#

sudo mount --uuid $NEW_VFAT_UUID $MOUNT_BOOT

# shellcheck disable=SC2155
export OLD_EXT4_UUID=$(sudo egrep -o -e '[0-9a-f\-]{36}' $MOUNT_BOOT/EFI/ubuntu/grub.cfg)
echo OLD: $OLD_EXT4_UUID
echo NEW: $NEW_EXT4_UUID

sudo sed -i "s/$OLD_EXT4_UUID/$NEW_EXT4_UUID/g" $MOUNT_BOOT/EFI/ubuntu/grub.cfg

sudo cat $MOUNT_BOOT/EFI/ubuntu/grub.cfg

#
# Adjust /etc/fstab for new UUIDs.
#

sudo mount --uuid $NEW_EXT4_UUID $MOUNT_ROOT

# shellcheck disable=SC2155
export OLD_EXT4_UUID=$(sudo egrep -o -e '[0-9a-f\-]{36}' $MOUNT_ROOT/etc/fstab)
echo OLD: $OLD_EXT4_UUID
echo NEW: $NEW_EXT4_UUID

sudo sed -i "s/$OLD_EXT4_UUID/$NEW_EXT4_UUID/g" $MOUNT_ROOT/etc/fstab

# shellcheck disable=SC2155
export OLD_VFAT_UUID=$(sudo egrep -o -e '[0-9A-F\-]{9}' $MOUNT_ROOT/etc/fstab)
echo OLD: $OLD_VFAT_UUID
echo NEW: $NEW_VFAT_UUID

sudo sed -i "s/$OLD_VFAT_UUID/$NEW_VFAT_UUID/g" $MOUNT_ROOT/etc/fstab

sudo cat $MOUNT_ROOT/etc/fstab

#
# Postprocessing.
#

sudo umount $MOUNT_BOOT
sudo umount $MOUNT_ROOT
rmdir $MOUNT_BOOT
rmdir $MOUNT_ROOT
