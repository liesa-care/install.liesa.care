#!/bin/bash

#
# Repackage bluez with HOG disabled.
#

export ARCH=amd64

export GLIB2VERSION=2.77.1-2
export GLIB2=libglib2.0-0_$GLIB2VERSION

export BLUEZVERSION=5.68-0ubuntu1
export BLUEZ=bluez_$BLUEZVERSION

export REPO=~/go/src/github.com/liesa-care/install.liesa.care

go get github.com/liesa-care/install.liesa.care
cd $REPO
git pull

#
# Unpack deb files.
#

cd
rm -rf bluez-patch
mkdir bluez-patch
cd bluez-patch

cp $REPO/bluetooth/${GLIB2}_$ARCH.deb .
cp $REPO/bluetooth/${BLUEZ}_$ARCH.deb .

mkdir ${GLIB2}_$ARCH
dpkg-deb -R ${GLIB2}_$ARCH.deb ${GLIB2}_$ARCH

mkdir ${BLUEZ}_$ARCH
dpkg-deb -R ${BLUEZ}_$ARCH.deb ${BLUEZ}_$ARCH

sudo sed -i "s/Version: $GLIB2VERSION/Version: $GLIB2VERSION-dezi/g" ${GLIB2}_$ARCH/DEBIAN/control
sudo sed -i "s/Version: $BLUEZVERSION/Version: $BLUEZVERSION-dezi/g" ${BLUEZ}_$ARCH/DEBIAN/control

cp ${GLIB2}_$ARCH/DEBIAN/control ${GLIB2}-dezi_$ARCH.txt
cp ${BLUEZ}_$ARCH/DEBIAN/control ${BLUEZ}-dezi_$ARCH.txt

sudo apt-get build-dep bluez

git clone https://kernel.googlesource.com/pub/scm/libs/ell/ell.git
git clone git@github.com:dezi/bluez.git
cd bluez

./bootstrap

./configure --prefix=/usr --mandir=/usr/share/man \
	--sysconfdir=/etc --localstatedir=/var \
	--disable-hog

make

strip ./src/bluetoothd
cp ./src/bluetoothd ../${BLUEZ}_$ARCH/usr/lib/bluetooth

cd
cd bluez-patch
dpkg-deb -b ${GLIB2}_$ARCH ${GLIB2}-dezi_$ARCH.deb
dpkg-deb -b ${BLUEZ}_$ARCH ${BLUEZ}-dezi_$ARCH.deb

curl -X PUT -d @${GLIB2}-dezi_$ARCH.deb  -H "Dezis-Secret: ouzo" \
  https://apt1.liesa.care/dpkg/dists/unstable/main/binary-$ARCH/${GLIB2}-dezi_$ARCH.deb
curl -X PUT -d @${GLIB2}-dezi_$ARCH.deb  -H "Dezis-Secret: ouzo" \
  https://apt2.liesa.care/dpkg/dists/unstable/main/binary-$ARCH/${GLIB2}-dezi_$ARCH.deb

curl -X PUT -d @${GLIB2}-dezi_$ARCH.txt  -H "Dezis-Secret: ouzo" \
  https://apt1.liesa.care/dpkg/dists/unstable/main/binary-$ARCH/${GLIB2}-dezi_$ARCH.txt
curl -X PUT -d @${GLIB2}-dezi_$ARCH.txt  -H "Dezis-Secret: ouzo" \
  https://apt2.liesa.care/dpkg/dists/unstable/main/binary-$ARCH/${GLIB2}-dezi_$ARCH.txt

curl -X PUT -d @${BLUEZ}-dezi_$ARCH.deb  -H "Dezis-Secret: ouzo" \
  https://apt1.liesa.care/dpkg/dists/unstable/main/binary-$ARCH/${BLUEZ}-dezi_$ARCH.deb
curl -X PUT -d @${BLUEZ}-dezi_$ARCH.deb  -H "Dezis-Secret: ouzo" \
  https://apt2.liesa.care/dpkg/dists/unstable/main/binary-$ARCH/${BLUEZ}-dezi_$ARCH.deb

curl -X PUT -d @${BLUEZ}-dezi_$ARCH.txt  -H "Dezis-Secret: ouzo" \
  https://apt1.liesa.care/dpkg/dists/unstable/main/binary-$ARCH/${BLUEZ}-dezi_$ARCH.txt
curl -X PUT -d @${BLUEZ}-dezi_$ARCH.txt  -H "Dezis-Secret: ouzo" \
  https://apt2.liesa.care/dpkg/dists/unstable/main/binary-$ARCH/${BLUEZ}-dezi_$ARCH.txt
