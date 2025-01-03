#!/bin/bash

#
# Repackage bluez with HOG disabled
# and dezi's patches applied.
#

export ARCH=$(dpkg --print-architecture)

export REPO=~/go/src/github.com/liesa-care/install.liesa.care

export BLUEZSOURCE=5.72
export BLUEZTARGET=5.79
export BLUEZSOURCENAME=bluez_$BLUEZSOURCE-0ubuntu5_$ARCH
export BLUEZTARGETNAME=bluez_$BLUEZTARGET-0ubuntu5-dezi_$ARCH

#
# /etc/apt/sources.list
# deb-src http://de.archive.ubuntu.com/ubuntu/ jammy main restricted
# deb-src http://de.archive.ubuntu.com/ubuntu/ noble main restricted
#
sudo apt-get build-dep bluez

#
# Update install repository containing
# templates and patches.
#

cd $REPO
git pull

#
# Fetch and patch bluez source.
#

cd
rm -rf bluez-final
mkdir bluez-final
cd bluez-final

wget https://mirrors.edge.kernel.org/pub/linux/libs/ell/ell-0.70.tar.gz
tar xvf ./ell-0.70.tar.gz
mv ell-0.70 ell
cd ell
./configure --prefix=/usr
make
sudo make install

cd
cd bluez-final

git clone https://github.com/bluez/bluez.git

cd bluez
git checkout $BLUEZTARGET
git apply $REPO/bluetooth/patch.txt

./bootstrap

./configure --prefix=/usr --mandir=/usr/share/man \
	--sysconfdir=/etc --localstatedir=/var \
	--disable-hog

make

strip ./src/bluetoothd
strip ./client/bluetoothctl

cd
cd bluez-final

#
# Unpack debian package.
#

apt download bluez

rm -rf "$BLUEZSOURCENAME"
mkdir "$BLUEZSOURCENAME"
dpkg-deb -R "$BLUEZSOURCENAME".deb "$BLUEZSOURCENAME"

#
# Patch and copy control file.
#

sudo sed -i "s/Version: $BLUEZSOURCE-0ubuntu5/Version: $BLUEZTARGET-0ubuntu5-dezi/g" $BLUEZSOURCENAME/DEBIAN/control
cp $BLUEZSOURCENAME/DEBIAN/control ${BLUEZTARGETNAME}.txt

#
# Replace binaries with newer version.
#

cp bluez/src/bluetoothd $BLUEZSOURCENAME/usr/libexec/bluetooth/bluetoothd
cp bluez/client/bluetoothctl $BLUEZSOURCENAME/usr/bin/bluetoothctl

#
# Repack debian package.
#

dpkg-deb -b $BLUEZSOURCENAME $BLUEZTARGETNAME.deb

export BLUEZMD5=$(md5sum ${BLUEZTARGETNAME}.deb | egrep -o -e '[0-9a-f]{32}')
export BLUEZSHA1=$(sha1sum ${BLUEZTARGETNAME}.deb | egrep -o -e '[0-9a-f]{40}')
export BLUEZSHA256=$(sha256sum ${BLUEZTARGETNAME}.deb | egrep -o -e '[0-9a-f]{64}')
export BLUEZFILE="dists/unstable/main/binary-all/${BLUEZTARGETNAME}.deb"
export BLUEZSIZE=$(wc -c < ${BLUEZTARGETNAME}.deb)

#
# Create package infos.
#

tee -a ${BLUEZTARGETNAME}.txt << EOF
Size: $BLUEZSIZE
SHA1: $BLUEZSHA1
SHA256: $BLUEZSHA256
MD5sum: $BLUEZMD5
Filename: $BLUEZFILE
EOF

echo "----------------"
cat ${BLUEZTARGETNAME}.txt
echo "----------------"

#
# Upload new package to all servers.
#

curl -X PUT --data-binary @${BLUEZTARGETNAME}.deb  -H "Dezis-Secret: ouzo" \
  https://api1.liesa-care.xyz/dpkg/dists/unstable/main/binary-all/${BLUEZTARGETNAME}.deb
curl -X PUT --data-binary @${BLUEZTARGETNAME}.deb  -H "Dezis-Secret: ouzo" \
  https://api2.liesa-care.xyz/dpkg/dists/unstable/main/binary-all/${BLUEZTARGETNAME}.deb

curl -X PUT --data-binary @${BLUEZTARGETNAME}.txt  -H "Dezis-Secret: ouzo" \
  https://api1.liesa-care.xyz/dpkg/dists/unstable/main/binary-all/${BLUEZTARGETNAME}.txt
curl -X PUT --data-binary @${BLUEZTARGETNAME}.txt  -H "Dezis-Secret: ouzo" \
  https://api2.liesa-care.xyz/dpkg/dists/unstable/main/binary-all/${BLUEZTARGETNAME}.txt
