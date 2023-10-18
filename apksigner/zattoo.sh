#!/bin/sh

#
# cat data/data/com.zattoo.player/shared_prefs/zattoo.prefs.xml
#

cd ~/tv-apps/tvbox

cp ~/go/src/github.com/dezi/project.java.tvbox/app/build/outputs/apk/debug/app-debug.apk de.kappa.tvbox.apk

rm -rf de.kappa.tvbox

apktool if de.kappa.tvbox.apk
apktool d de.kappa.tvbox.apk

rm -rf ~/tv-apps/zattoo/com.zattoo.player/smali/patch
cp -rp ~/tv-apps/tvbox/de.kappa.tvbox/smali_classes20/patch ~/tv-apps/zattoo/com.zattoo.player/smali










cd ~/tv-apps/zattoo

rm -rf com.zattoo.player

apktool if com.zattoo.player.apk
apktool d com.zattoo.player.apk

cd ~/tv-apps/zattoo

# fuck it now.

cd ~/tv-apps/zattoo
apktool b com.zattoo.player --use-aapt2 -o com.zattoo.player.repacked.apk

~/Library/Android/sdk/build-tools/33.0.0/zipalign -v -p -f 4 com.zattoo.player.repacked.apk com.zattoo.player.aligned.apk

cp com.zattoo.player.aligned.apk com.zattoo.player.resigned.apk
~/Library/Android/sdk/build-tools/33.0.0/apksigner sign --ks ../release.keystore com.zattoo.player.resigned.apk << EOF
blabla
EOF

adb connect 192.168.178.40:5555
adb -s 192.168.178.40:5555 install -r com.zattoo.player.resigned.apk


