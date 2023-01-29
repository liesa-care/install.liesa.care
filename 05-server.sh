#!/bin/bash

#
# Basic setup for server box.
#

### Add Local User
sudo addgroup dezi --gid 1001
sudo adduser dezi --uid 1001 -gid 1001

sudo adduser dezi sudo
sudo adduser dezi adm
sudo adduser dezi dialout
sudo adduser dezi cdrom
sudo adduser dezi floppy
sudo adduser dezi audio
sudo adduser dezi dip
sudo adduser dezi video
sudo adduser dezi plugdev
sudo adduser dezi netdev
sudo adduser dezi lxd
sudo adduser dezi input
