#!/bin/bash

#
# Repackage bluez with HOG disabled.
#

export ARCH=$(dpkg --print-architecture)

export BLUEZVERSION=5.73-0ubuntu1
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

cp $REPO/bluetooth/${BLUEZ}_$ARCH.deb .

rm -rf ${BLUEZ}_$ARCH
mkdir ${BLUEZ}_$ARCH
dpkg-deb -R ${BLUEZ}_$ARCH.deb ${BLUEZ}_$ARCH

#
# Do manually!!!!
#
sudo sed -i "s/Version: $BLUEZVERSION/Version: $BLUEZVERSION-dezi/g" ${BLUEZ}_$ARCH/DEBIAN/control

cp ${BLUEZ}_$ARCH/DEBIAN/control ${BLUEZ}-dezi_$ARCH.txt

sudo apt-get build-dep bluez

git clone https://kernel.googlesource.com/pub/scm/libs/ell/ell.git
git clone git@github.com:dezi/bluez.git
cd bluez

#
# in src/gatt-database.c
# around 675
#
# device = btd_adapter_get_device(adapter, &dst, dst_type);
#	if (!device || !btd_device_is_connected(device)) {
#	    DBG("tubu kicksi no fuck!")
#		return;
#	}

./bootstrap

./configure --prefix=/usr --mandir=/usr/share/man \
	--sysconfdir=/etc --localstatedir=/var \
	--disable-hog

make

strip ./src/bluetoothd
cp ./src/bluetoothd ../${BLUEZ}_$ARCH/usr/lib/bluetooth

cd
cd bluez-patch
dpkg-deb -b ${BLUEZ}_$ARCH ${BLUEZ}-dezi_$ARCH.deb

export BLUEZMD5=$(md5sum ${BLUEZ}-dezi_$ARCH.deb | egrep -o -e '[0-9a-f]{32}')
export BLUEZSHA1=$(sha1sum ${BLUEZ}-dezi_$ARCH.deb | egrep -o -e '[0-9a-f]{40}')
export BLUEZSHA256=$(sha256sum ${BLUEZ}-dezi_$ARCH.deb | egrep -o -e '[0-9a-f]{64}')
export BLUEZFILE="dists/unstable/main/binary-all/${BLUEZ}-dezi_$ARCH.deb"
export BLUEZSIZE=$(wc -c < ${BLUEZ}-dezi_$ARCH.deb)

tee -a ${BLUEZ}-dezi_$ARCH.txt << EOF
Size: $BLUEZSIZE
SHA1: $BLUEZSHA1
SHA256: $BLUEZSHA256
MD5sum: $BLUEZMD5
Filename: $BLUEZFILE
EOF

curl -X PUT --data-binary @${BLUEZ}-dezi_$ARCH.deb  -H "Dezis-Secret: ouzo" \
  https://api1.liesa.care/dpkg/dists/unstable/main/binary-all/${BLUEZ}-dezi_$ARCH.deb
curl -X PUT --data-binary @${BLUEZ}-dezi_$ARCH.deb  -H "Dezis-Secret: ouzo" \
  https://api2.liesa.care/dpkg/dists/unstable/main/binary-all/${BLUEZ}-dezi_$ARCH.deb

curl -X PUT --data-binary @${BLUEZ}-dezi_$ARCH.txt  -H "Dezis-Secret: ouzo" \
  https://api1.liesa.care/dpkg/dists/unstable/main/binary-all/${BLUEZ}-dezi_$ARCH.txt
curl -X PUT --data-binary @${BLUEZ}-dezi_$ARCH.txt  -H "Dezis-Secret: ouzo" \
  https://api2.liesa.care/dpkg/dists/unstable/main/binary-all/${BLUEZ}-dezi_$ARCH.txt
