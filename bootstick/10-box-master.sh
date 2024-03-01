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

echo "SSH Key Generation"
cd
if test -d ".ssh"; then
  echo "Already done..."
else
  ssh-keygen
  ssh-copy-id localhost
fi

echo "Install additional packages"
sudo apt install -y \
  iw adb git nmap ffmpeg autofs hwinfo \
  v4l-utils net-tools pavucontrol build-essential \
  libsbc-dev libbluetooth-dev zlib1g-dev libssl-dev \
  cpufrequtils speedtest-cli wireless-tools network-manager \
  libdbus-1-dev libudev-dev libical-dev libreadline-dev \
  libssl-dev zlib1g-dev libasound2-dev upower alsa-utils \
  libopus-dev libopusfile-dev pkg-config \
  mosquitto mosquitto-clients

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

echo "Liesa Care APT Repository"
APT_PRESENT=$(grep apt.liesa.care /etc/apt/sources.list)
if [ -n "$APT_PRESENT" ]; then
  echo "Already done..."
else
  sudo tee -a /etc/apt/sources.list << EOF
deb [trusted=yes] http://apt.liesa.care/dpkg unstable main
EOF
fi

echo "Remove Desktop Integration Bug"
sudo snap remove snapd-desktop-integration

echo "Install node"
sudo snap install node --classic

echo "Set Bluetooth to Compat Mode"
BT_CONFIG="/etc/systemd/system/dbus-org.bluez.service"
BT_OLD="ExecStart=/usr/lib/bluetooth/bluetoothd"
BT_NEW="ExecStart=/usr/lib/bluetooth/bluetoothd --compat"
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

echo "Suppress non working bluetooth devices"
if test -f "/etc/udev/rules.d/disable-usb-bluetooth.rules"; then
  echo "Already done..."
else
  sudo tee /etc/udev/rules.d/disable-usb-bluetooth.rules << EOF
ACTION=="add", ATTR{idVendor}=="13d3", ATTR{idProduct}=="3503", RUN="/bin/sh -c 'echo 0 >/sys/\$devpath/authorized'"
EOF
fi

echo "User Groups"
sudo adduser $USER sudo
sudo adduser $USER input
sudo adduser $USER audio
sudo adduser $USER video
sudo adduser $USER netdev
sudo adduser $USER plugdev
sudo adduser $USER dialout

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

sudo apt -y update
sudo apt -y autoremove
sudo apt -y clean

sudo apt -y install box.webdog.debug
