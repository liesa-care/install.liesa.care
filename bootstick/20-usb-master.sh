#!/bin/sh

#
# Create an ubuntu bootable device
# which is a liesa care usb master.
#
# Do an Ubuntu 22.4.x LTS
# minimum desktop install with:
#
# Language: English
# Name: Liesa Care
# User: liesa
#

#
# Via desktop login in terminal:
#

sudo apt -y install openssh-server

#
# Do this section via ssh.
#

sudo apt -y update
sudo apt -y upgrade

echo "Enable fucking USB 2.0 mode on Minis Forum HM50 etc."
MMU_PRESENT=$(grep amd_iommu=on /etc/default/grub)
if [ -n "$MMU_PRESENT" ]; then
  echo "Already done..."
else
  sudo sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="amd_iommu=on iommu.passthrough=on"/g' /etc/default/grub
  sudo update-grub
fi

echo "Liesa Care APT Repository"
APT_PRESENT=$(grep apt.liesa.care /etc/apt/sources.list)
if [ -n "$APT_PRESENT" ]; then
  echo "Already done..."
else
  sudo tee -a /etc/apt/sources.list << EOF
deb [trusted=yes] http://apt.liesa.care/dpkg unstable main
EOF
fi

sudo apt -y update
sudo apt -y autoremove
sudo apt -y clean

#
# Check /etc/fstab
#
# Fucking Ubuntu installer tends to mount
# the build in disk boot partition for this
# USB stick. So get the real partition id
# and correct it manually.
#
# Correct mounts:
#
# /dev/sdb2       58310644 8276088  47040076  15% /
# /dev/sdb1         523248       4    523244   1% /boot/efi
#
# Fucked up mounts:
#
# /dev/sdb2       58310644 8276088  47040076  15% /
# /dev/sda1         523248       4    523244   1% /boot/efi
#
# In this case sudo vi /etc/fstab and fix the uuids.
#

sudo apt -y install box.webmak.debug

