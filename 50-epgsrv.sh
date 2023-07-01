#!/bin/bash

#
# Setup for EPG scraper box.
#

echo "Get DVB-C Stick Firmware"
cd /lib/firmware
##sudo wget http://palosaari.fi/linux/v4l-dvb/firmware/Si2168/Si2168-B40/4.0.25/dvb-demod-si2168-b40-01.fw
sudo wget https://raw.githubusercontent.com/liesa-care/install.liesa.care/main/tvheadend/dvb-demod-m88ds3103.fw
sudo wget https://raw.githubusercontent.com/liesa-care/install.liesa.care/main/tvheadend/dvb-demod-m88rs6000.fw
sudo wget https://raw.githubusercontent.com/liesa-care/install.liesa.care/main/tvheadend/dvb-demod-si2168-b40-01.fw

echo "Add TvHeadend Repository"
sudo add-apt-repository ppa:mamarley/tvheadend-git
sudo apt update
sudo apt install -y tvheadend

echo "Stopping TvHeadend Service"
sudo service tvheadend stop

echo "Set Running User"
sudo sed -i "s/-u hts -g video -6/-u $USER -g video -C/g" /etc/default/tvheadend
sudo sed -i "s/TVH_USER=\"hts\"/TVH_USER=\"$USER\"/g" /etc/default/tvheadend

echo "Fix Fucked Up de-Kabel_Deutschland-Hannover Mux Listing"
wget https://raw.githubusercontent.com/liesa-care/install.liesa.care/main/tvheadend/de-Kabel_Deutschland-Dezi
sudo mv de-Kabel_Deutschland-Dezi /usr/share/tvheadend/data/dvb-scan/dvb-c

echo "Change TvHeadend running user"
rm -rf .hts
sudo mv ../hts/.hts .
sudo chown -R ${USER} .hts
sudo chgrp -R ${USER} .hts

echo "Remove TvHeadend User"
sudo deluser hts
sudo rm -r /home/hts

echo "Start TvHeadend Service"
sudo service tvheadend start

echo "Setup On Boot Compile"
if test -f ~/.onboot; then
  echo "Already done..."
else
  tee .onboot << EOF
#!/bin/bash
sudo killall epgsrv
cd ~/go/src/github.com/liesa-care
cd project.go.liesa.main; git pull; cd ..
cd ~/go/src/github.com/dezi
cd project.go.server; git pull; cd ..
cd packs.go.goodies; git pull; cd ..
go build -o epgsrv project.go.server/roles/epgsrv/main.go
nohup ./epgsrv >/dev/null 2>&1 </dev/null &
EOF
  chmod a+x .onboot
fi

echo "Setup Nightly Reboot"
sudo tee -a /etc/crontab << EOF
0 4   *   *   *    /sbin/shutdown -r +5
EOF
