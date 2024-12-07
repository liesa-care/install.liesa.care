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

echo "Liesa-Care Repositories"
cd
mkdir -p go/src/github.com
if test -d "go/src/github.com/liesa-care"; then
  echo "Already done..."
else
  cd go/src/github.com
  mkdir liesa-care
  cd liesa-care
  git clone git@github.com:liesa-care/install.liesa.care
  git clone git@github.com:liesa-care/project.go.liesa.main.git
  cd project.go.liesa.main
fi

echo "Onboot script"
cd
if test -f ".onboot"; then
  echo "Already done..."
else
  tee .onboot << EOF
#!/bin/bash
. .profile
killall websen
cd ~/go/src/github.com/liesa-care/project.go.liesa.main
git checkout main
git pull
go build -o ../websen roles/websen/main.go
nohup ../websen >/dev/null 2>/opt/box/log/websen.err.log &
EOF
  chmod a+x .onboot
fi

echo "Crontab"
LINE1="@reboot sleep 10 && ssh localhost sleep 999999d"
LINE2="@reboot sleep 10 && ssh localhost ~/.onboot >~/.onboot.log 2>&1"
echo -e "$LINE1\n$LINE2" | crontab -
