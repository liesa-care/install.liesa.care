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
