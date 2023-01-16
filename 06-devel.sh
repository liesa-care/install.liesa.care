#!/bin/bash

#
# Development setup for source box.
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

echo "Dezi Repositories"
cd
if test -d "go/src/github.com/dezi"; then
  echo "Already done..."
else
  cd go/src/github.com
  mkdir dezi
  cd dezi
  git clone git@github.com:dezi/project.go.server.git
  git clone git@github.com:dezi/packs.go.goodies.git
fi

echo "Forked Repositories"

if test -d "go/src/github.com/muka"; then
  echo "Already done..."
else
  cd ~/go/src/github.com
  mkdir muka
  cd muka
  git clone git@github.com:dezi/go-bluetooth.git
fi

if test -d "go/src/github.com/go-ble"; then
  echo "Already done..."
else
  cd ~/go/src/github.com
  mkdir go-ble
  cd go-ble
  git clone git@github.com:dezi/ble.git
fi

if test -d "go/src/github.com/gocv.io"; then
  echo "Already done..."
else
  cd ~/go/src
  mkdir gocv.io
  cd gocv.io
  mkdir x
  cd x
  git clone git@github.com:dezi/gocv.git
fi

echo "Open Source Repositories"
cd

go get golang.org/x/sys/unix
go get golang.org/x/crypto/curve25519
go get golang.org/x/crypto/acme/autocert

go get github.com/NYTimes/gziphandler

go get cloud.google.com/go/speech/apiv1
