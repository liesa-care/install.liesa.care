#!/bin/bash

#
# Setup for EPG scraper box.
#

echo "Get DVB-C Stick Firmware"
cd /lib/firmware
sudo wget http://palosaari.fi/linux/v4l-dvb/firmware/Si2168/Si2168-B40/4.0.25/dvb-demod-si2168-b40-01.fw

echo "Add TvHeadend Repository"
sudo add-apt-repository ppa:mamarley/tvheadend-git
sudo apt update
sudo apt install -y tvheadend

echo "Stopping TvHeadend Service"
sudo service tvheadend stop

echo "Change TvHeadend running user"
rm -rf .hts
sudo mv ../hts/.hts .
sudo chown -R ${USER} .hts
sudo chgrp -R ${USER} .hts

echo "Remove TvHeadend User"
sudo deluser hts
sudo rm -r /home/hts

sudo vi /etc/default/tvheadend
#...
#-OPTIONS="-u hts -g video -6"
#+OPTIONS="-u ${USER} -g video"
#...
#-TVH_USER="hts"
#+TVH_USER="${USER}"
#...

echo "Start TvHeadend Service"
sudo service tvheadend start

echo "Setup Nightly Reboot"
sudo tee -a /etc/crontab << EOF
0 4   *   *   *    /sbin/shutdown -r +5
EOF
