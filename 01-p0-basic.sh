#!/bin/bash

#
# Basic setup for pi zero (not pi zero 2!).
#

echo "Allow sudo w/o password"
NOPASSWD=$(sudo grep NOPASSWD /etc/sudoers)
if [ -n "$NOPASSWD" ]; then
  echo "Already done..."
else
  sudo sed -i 's/%sudo\tALL=(ALL:ALL) ALL/%sudo\tALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers
fi

echo "Force apt to IPV4"
if test -f "/etc/apt/apt.conf.d/90force-ipv4"; then
  echo "Already done..."
else
  echo 'Acquire::ForceIPv4 "true";' | sudo tee /etc/apt/apt.conf.d/90force-ipv4
fi

#echo "SSH Key Generation"
#cd
#if test -d ".ssh"; then
#  echo "Already done..."
#else
#  ssh-keygen
#  ssh-copy-id localhost
#fi

echo "Install Debian Updates"
export DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt upgrade -y

echo "Install additional packages"
sudo apt install -y \
  iw adb git bluez nmap ffmpeg autofs hwinfo \
  v4l-utils net-tools pavucontrol build-essential \
  libsbc-dev libbluetooth-dev zlib1g-dev libssl-dev \
  cpufrequtils speedtest-cli wireless-tools network-manager \
  libdbus-1-dev libudev-dev libical-dev libreadline-dev \
  libssl-dev zlib1g-dev libasound2-dev upower alsa-utils \
  libopus-dev libopusfile-dev pkg-config \
  mosquitto mosquitto-clients pulseaudio \
  libavcodec-dev libavutil-dev libswscale-dev

sudo apt autoremove -y

echo "Setup Udev USB Auto Mount"
if test -f "/etc/udev/rules.d/99-usb.auto-mount.rules"; then
  echo "Already done..."
else
  sudo mkdir /media/auto-usb
  sudo mkdir /media/usb-sticks
  sudo tee /etc/udev/rules.d/99-usb.auto-mount.rules << EOF
ACTION=="add", KERNEL=="sd*", ENV{DEVTYPE}=="partition", ENV{ID_BUS}=="usb", \\
    SYMLINK+="usbdisks/%k", MODE:="0660", \\
    RUN+="/bin/rm /media/usb-sticks/%k", \\
    RUN+="/bin/ln -sf /media/auto-usb/%k /media/usb-sticks/%k"
ACTION=="remove", KERNEL=="sd*", ENV{DEVTYPE}=="partition", ENV{ID_BUS}=="usb", \\
    RUN+="/bin/rm /media/usb-sticks/%k"
EOF
  sudo udevadm control --reload-rules
fi

echo "Setup autofs USB Auto Mount"
if test -f "/etc/auto.master.d/usb.autofs"; then
  echo "Already done..."
else
  sudo tee /etc/auto.master.d/usb.autofs << EOF
/media/auto-usb /etc/auto.usb --ghost
EOF
  sudo tee /etc/auto.usb << EOF
#!/bin/bash
fstype=\$(/sbin/blkid -o value -s TYPE /dev/usbdisks/\${1})
if [ "\${fstype}" = "vfat" ] ; then
  echo "-fstype=vfat,sync,uid=0,gid=plugdev,umask=000 :/dev/usbdisks/\${1}"
  exit 0
fi
exit 1
EOF
  sudo chmod a+x /etc/auto.usb
  sudo service autofs reload
  sudo systemctl daemon-reload
fi

echo "User Groups"
sudo adduser $USER sudo
sudo adduser $USER input
sudo adduser $USER audio
sudo adduser $USER video
sudo adduser $USER netdev
sudo adduser $USER plugdev
sudo adduser $USER dialout
sudo adduser $USER gpio

echo "Aliases and Paths"
cd
if test -f ".profile.bak"; then
  echo "Already done..."
else
  cp .profile .profile.bak
  cat >> .profile << EOF
# Liesa-Care additions.
export PATH=$PATH:/usr/local/go/bin
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
alias psg='ps -eaf | grep -v grep | grep'
alias ta="tail -f /opt/box/log/websen.log"
alias ll="ls -alh"
alias du="du -h"
alias df="df -h"
EOF
. .profile
fi

echo "GO Install"
if test -d "/usr/local/go"; then
  echo "Already done..."
else
  GO_VERSION="go1.23.3"
  #APT_ARCH=$(dpkg --print-architecture)
  APT_ARCH="armv6l"
  cd
  mkdir goinst
  cd goinst
  wget https://golang.org/dl/$GO_VERSION.linux-$APT_ARCH.tar.gz
  tar xvzf $GO_VERSION.linux-$APT_ARCH.tar.gz
  sudo rm -rf /usr/local/go
  sudo mv go /usr/local
  go env -w GO111MODULE=auto
  rm $GO_VERSION.linux-$APT_ARCH.tar.gz
  cd
  rmdir goinst
  mkdir -p ~/go/src/github.com
  go version
fi

echo "Box Directory"
if test -d "/opt/box"; then
  echo "Already done..."
else
  sudo mkdir /opt/box
  sudo chown $USER /opt/box
  sudo chgrp $USER /opt/box
# sudo chgrp staff /opt/box
  mkdir /opt/box/etc
  mkdir /opt/box/log
  mkdir /opt/box/var
  mkdir /opt/box/gen
  mkdir /opt/box/dev
fi

echo "Setup Hardware Serial Number"
cp /sys/firmware/devicetree/base/serial-number /opt/box/etc/boxserial.txt

#echo "Setup Box Owner Email"
#if test -f "/opt/box/etc/boxowner.txt"; then
#  echo "Already done..."
#else
#  echo "Please enter Your email (required to access box via app):"
#  read -r email
#  echo "$email" > /opt/box/etc/boxowner.txt
#fi

#echo "Box APT Repository"
#APT_PRESENT=$(grep apt.liesa-care.xyz /etc/apt/sources.list)
#if [ -n "$APT_PRESENT" ]; then
#  echo "Already done..."
#else
#  sudo tee -a /etc/apt/sources.list << EOF
#deb [trusted=yes] http://apt2.liesa-care.xyz/dpkg unstable main
#EOF
#  sudo apt update
#fi
