#!/bin/bash

export ARCH=arm64
export GLIB2=libglib2.0-0_2.77.1-2
export BLUEZ=bluez_5.68-0ubuntu1

#
# Unpack deb files.
#





./configure --prefix=/usr --mandir=/usr/share/man \
	--sysconfdir=/etc --localstatedir=/var \
	--enable-external-ell --disable-hog
