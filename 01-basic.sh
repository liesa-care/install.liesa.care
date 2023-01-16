#!/bin/bash

echo "Force apt to IPV4"
if test -f "/etc/apt/apt.conf.d/90force-ipv4"; then
  echo "Already done..."
else
  echo 'Acquire::ForceIPv4 "true";' | sudo tee /etc/apt/apt.conf.d/90force-ipv4
fi

echo "Allow sudo w/o password"
sudo sed -i 's/%sudo    ALL=(ALL:ALL) ALL/%sudo    ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers

echo "Install Ubuntu Updates"
export DEBIAN_FRONTEND=noninteractive
sudo apt update
sudo apt upgrade -y

echo "Install additional packages"
sudo apt install -y adb
sudo apt install -y nmap
sudo apt install -y ffmpeg
sudo apt install -y v4l-utils
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
  MYSELF=$(whoami)
  sudo mkdir /opt/box
  sudo chown $MYSELF /opt/box
  sudo chgrp $MYSELF /opt/box
  mkdir /opt/box/etc
  mkdir /opt/box/log
  mkdir /opt/box/var
  mkdir /opt/box/gen
  mkdir /opt/box/dev
fi
