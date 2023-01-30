#!/bin/bash

#
# Basic setup for normal box.
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
sudo apt install -y iw adb git nmap ffmpeg autofs hwinfo
sudo apt install -y v4l-utils net-tools pavucontrol build-essential
sudo apt install -y libsbc-dev libbluetooth-dev zlib1g-dev libssl-dev
sudo apt install -y cpufrequtils speedtest-cli wireless-tools network-manager
sudo apt install -y libdbus-1-dev libudev-dev libical-dev libreadline-dev
sudo apt install -y libssl-dev zlib1g-dev

sudo apt autoremove -y

echo "Remove Desktop Integration Bug"
sudo snap remove snapd-desktop-integration

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
fi

echo "User Groups"
sudo adduser $USER input
sudo adduser $USER audio
sudo adduser $USER video
sudo adduser $USER netdev
sudo adduser $USER plugdev

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

echo "Enable user background processes"
sudo loginctl enable-linger $USER
sudo sed -i 's/#KillUserProcesses=no/KillUserProcesses=no/g' /etc/systemd/logind.conf

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
# sudo chgrp staff /opt/box
  mkdir /opt/box/etc
  mkdir /opt/box/log
  mkdir /opt/box/var
  mkdir /opt/box/gen
  mkdir /opt/box/dev
fi

echo "Setup Hardware Serial Number"
if test -f "/opt/box/etc/boxserial.txt"; then
  echo "Already done..."
else
  echo "Please enter serial number:"
  read -r serial
  echo "$serial" > /opt/box/etc/boxserial.txt
fi

echo "Setup Box Owner Email"
if test -f "/opt/box/etc/boxowner.txt"; then
  echo "Already done..."
else
  echo "Please enter Your email (required to access box via app):"
  read -r email
  echo "$email" > /opt/box/etc/boxowner.txt
fi

echo "Box APT Repository"
APT_PRESENT=$(grep raspi.hopto.org /etc/apt/sources.list)
if [ -n "$APT_PRESENT" ]; then
  echo "Already done..."
else
  sudo tee -a /etc/apt/sources.list << EOF
deb [trusted=yes] http://raspi.hopto.org/dpkg unstable main
EOF
  sudo apt update
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
LINE1="@reboot sleep 10 && ssh localhost sleep 999999d"
LINE2="@reboot sleep 10 && ssh localhost ~/.onboot >~/.onboot.log 2>&1"
echo -e "$LINE1\n$LINE2" | crontab -
