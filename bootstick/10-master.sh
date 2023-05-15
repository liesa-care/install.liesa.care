#!/bin/sh

#
# Create a ubuntu device which is a
# liesa care box master.
#

sudo apt -y install openssh-server

sudo apt -y update
sudo apt -y upgrade

echo "Box APT Repository"
APT_PRESENT=$(grep apt.liesa.care /etc/apt/sources.list)
if [ -n "$APT_PRESENT" ]; then
  echo "Already done..."
else
  sudo tee -a /etc/apt/sources.list << EOF
deb [trusted=yes] http://apt.liesa.care/dpkg unstable main
EOF
fi

sudo apt -y update
sudo apt -y install box.webdog.debug
sudo apt -y autoremove
sudo apt -y clean
