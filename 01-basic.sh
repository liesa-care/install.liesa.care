#!/bin/bash

#
# Basic setup for normal box.
#

echo "Force apt to IPV4"
if test -f "/etc/apt/apt.conf.d/90force-ipv4"; then
  echo "Already done..."
else
  echo 'Acquire::ForceIPv4 "true";' | sudo tee /etc/apt/apt.conf.d/90force-ipv4
fi

echo "Allow sudo w/o password"
NOPASSWD=$(sudo grep NOPASSWD /etc/sudoers)
if [ -n "$NOPASSWD" ]; then
  echo "Already done..."
else
  sudo sed -i 's/%sudo    ALL=(ALL:ALL) ALL/%sudo    ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers
fi

echo "SSH Key Generation"
cd
if test -d ".ssh"; then
  echo "Already done..."
else
  ssh-keygen
  ssh-copy-id localhost
fi

echo "Install Ubuntu Updates"
export DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt upgrade -y

echo "Install additional packages"
sudo apt install -y iw
sudo apt install -y adb
sudo apt install -y git
sudo apt install -y nmap
sudo apt install -y ffmpeg
sudo apt install -y v4l-utils
sudo apt install -y net-tools
sudo apt install -y pavucontrol
sudo apt install -y build-essential
sudo apt install -y libsbc-dev
sudo apt install -y libbluetooth-dev
sudo apt install -y zlib1g-dev
sudo apt install -y libssl-dev
sudo apt install -y speedtest-cli
sudo apt install -y wireless-tools
sudo apt install -y network-manager
sudo apt install -y libdbus-1-dev
sudo apt install -y libudev-dev
sudo apt install -y libical-dev
sudo apt install -y libreadline-dev
sudo apt install -y libssl-dev
sudo apt install -y zlib1g-dev

echo "Set Bluetooth to Compat Mode"
BT_CONFIG="/etc/systemd/system/dbus-org.bluez.service"
BT_OLD="ExecStart=/usr/lib/bluetooth/bluetoothd"
BT_NEW="ExecStart=/usr/lib/bluetooth/bluetoothd -d --compat"
BT_OK=$(sudo grep "$BT_NEW" $BT_CONFIG)
if [ -n "$BT_OK" ]; then
  echo "Already done..."
else
  sudo sed -i "s:$BT_OLD:$BT_NEW:g" $BT_CONFIG
fi

echo "User Groups"
sudo adduser $USER audio
sudo adduser $USER video

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
alias ta="tail -f /opt/box/log/webbox.log"
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
  GO_VERSION="go1.19.5"
  APT_ARCH=$(dpkg --print-architecture)
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
  mkdir /opt/box/etc
  mkdir /opt/box/log
  mkdir /opt/box/var
  mkdir /opt/box/gen
  mkdir /opt/box/dev
fi

echo "Box APT Repository"
APT_PRESENT=$(grep raspi.hopto.org /etc/apt/sources.list)
if [ -n "$APT_PRESENT" ]; then
  echo "Already done..."
else
  sudo tee -a /etc/apt/sources.list << EOF
deb [trusted=yes] http://raspi.hopto.org/dpkg unstable main
EOF
fi

echo "Box Package Telegram Library"
sudo apt install -y box.tdlib.binary

echo "Box Package Kaldi Binaries and Model"
sudo apt install -y box.kaldi.binary
sudo apt install -y box.kaldi.model.de
sudo tee /etc/ld.so.conf.d/kaldi.conf << EOF
/opt/box/kaldi/lib
EOF
sudo ldconfig

echo "Box Packages"
sudo apt install -y box.tvbox.apk.debug

sudo apt install -y box.sounds
sudo apt install -y box.tvinfo.de

sudo apt install -y box.cities.data.de
sudo apt install -y box.cities.infos.de
sudo apt install -y box.cities.taggers.de

sudo apt install -y box.osm.infos.de
sudo apt install -y box.osm.taggers.de

sudo apt install -y box.wikipedia.taggers.de
sudo apt install -y box.wikipedia.teasers.de

sudo apt install -y box.tmdb.taggers.de
sudo apt install -y box.tmdb.persons.de
sudo apt install -y box.tmdb.movies.de
sudo apt install -y box.tmdb.moviesplay.de-de
sudo apt install -y box.tmdb.series.de
sudo apt install -y box.tmdb.seriesplay.de-de

echo "Crontab"
echo "@reboot sleep 10 && ssh localhost ~/.onboot >~/.onboot.log 2>&1" | crontab -
