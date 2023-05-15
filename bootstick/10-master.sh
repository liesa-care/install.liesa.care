#!/bin/sh

sudo apt -y install openssh-server
sudo apt -y update
sudo apt -y upgrade
sudo apt -y autoremove

echo "Box APT Repository"
APT_PRESENT=$(grep apt.liesa.care /etc/apt/sources.list)
if [ -n "$APT_PRESENT" ]; then
  echo "Already done..."
else
  sudo tee -a /etc/apt/sources.list << EOF
deb [trusted=yes] http://apt.liesa.care/dpkg unstable main
EOF
  sudo apt update
fi

sudo apt -y install box.webdog.debug
