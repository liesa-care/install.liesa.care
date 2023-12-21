#!/bin/bash

#
# Development Setup for Source Box.
#

echo "Git Install"
sudo apt install -y git git-lfs
git lfs install --skip-repo

echo "Git Config (Dezi)"
cd
DEZI=$(grep dezi@kappa-mm.de .ssh/id_rsa.pub)
if [ -n "$DEZI" ]; then
  echo "Already done..."
else
  mkdir .ssh
  scp "dezi@dennis-mb:~/.ssh/id_rsa*" ~/.ssh
  ssh-copy-id localhost
  git config --global user.name "dezi"
  git config --global user.email "dezi@kappa-mm.de"
  git config --global pull.rebase false
fi

#echo "Dezi Repositories"
#cd
#if test -d "go/src/github.com/dezi"; then
#  echo "Already done..."
#else
#  cd go/src/github.com
#  mkdir dezi
#  cd dezi
#  git clone git@github.com:dezi/project.go.server.git
#  git clone git@github.com:dezi/packs.go.goodies.git
#fi

echo "Liesa-Care Repositories"
cd
if test -d "go/src/github.com/liesa-care"; then
  echo "Already done..."
else
  cd go/src/github.com
  mkdir liesa-care
  cd liesa-care
  git clone git@github.com:liesa-care/install.liesa.care
  git clone git@github.com:liesa-care/project.go.liesa.main.git
fi

#echo "Forked Repositories"
#cd
#if test -d "go/src/github.com/hajimehoshi"; then
#  echo "Already done..."
#else
#  cd ~/go/src/github.com
#  mkdir hajimehoshi
#  cd hajimehoshi
#  git clone git@github.com:dezi/oto.git
#fi

#cd
#if test -f "go/src/tinygo.org/x/bluetooth/.fork"; then
#  echo "Already done..."
#else
#  rm -rf ~/go/src/tinygo.org/x/bluetooth
#  mkdir -p ~/go/src/tinygo.org/x
#  cd ~/go/src/tinygo.org/x
#  git clone git@github.com:dezi/bluetooth.git
#  touch bluetooth/.fork
#fi

#cd
#if test -d "go/src/github.com/muka"; then
#  echo "Already done..."
#else
#  cd ~/go/src/github.com
#  mkdir muka
#  cd muka
#  git clone git@github.com:dezi/go-bluetooth.git
#fi

#if test -d "go/src/github.com/go-ble"; then
#  echo "Already done..."
#else
#  cd ~/go/src/github.com
#  mkdir go-ble
#  cd go-ble
#  git clone git@github.com:dezi/ble.git
#fi

if test -d "go/src/gocv.io/x"; then
  echo "Already done..."
else
  cd ~/go/src
  mkdir gocv.io
  cd gocv.io
  mkdir x
  cd x
  git clone git@github.com:dezi/gocv.git
fi

echo "Open Source Golang Repositories OSX only"
cd
go get github.com/raff/goble/xpc

echo "DPKG Utility OSX only"
cd
brew install dpkg

echo "Open Source Golang Repositories"
cd

go get github.com/moby/term
go get github.com/creack/pty
go get github.com/hraban/opus
go get github.com/fogleman/gg
go get github.com/esimov/pigo/core
go get github.com/blackjack/webcam
go get github.com/shopspring/decimal
go get github.com/muka/go-bluetooth
go get github.com/pemistahl/lingua-go
go get github.com/nyaruka/phonenumbers
go get github.com/andreburgaud/crypt2go

go get golang.org/x/sys/unix
go get golang.org/x/image/draw
go get golang.org/x/crypto/curve25519
go get golang.org/x/crypto/acme/autocert

go get github.com/go-ble/ble
go get github.com/pkg/errors
go get github.com/godbus/dbus
go get github.com/fatih/structs
go get github.com/mgutz/logxi/v1
go get github.com/gen2brain/malgo
go get github.com/sirupsen/logrus
go get github.com/zelenin/go-tdlib
go get github.com/pixiv/go-libjpeg
go get github.com/mssola/user_agent
go get github.com/NYTimes/gziphandler
go get github.com/go-playground/validator
go get github.com/eclipse/paho.mqtt.golang

go get googlemaps.github.io/maps
go get cloud.google.com/go/firestore
go get cloud.google.com/go/speech/apiv1

echo "Onboot script"
cd
if test -f ".onboot"; then
  echo "Already done..."
else
  tee .onboot << EOF
#!/bin/bash
killall webbox
cd ~/go/src/github.com/liesa-care
cd project.go.liesa.main; git pull; cd ..
cd project.go.liesa.main; sh goget.sh; cd ..
cd ~/go/src/github.com/dezi
cd project.go.server; git pull; cd ..
cd packs.go.goodies; git pull; cd ..
go build -o webbox project.go.server/roles/webbox/main.go
nohup ./webbox >/dev/null 2>&1 &
EOF
  chmod a+x .onboot
fi

echo "Crontab"
LINE1="@reboot sleep 10 && ssh localhost sleep 999999d"
LINE2="@reboot sleep 10 && ssh localhost ~/.onboot >~/.onboot.log 2>&1"
echo -e "$LINE1\n$LINE2" | crontab -
