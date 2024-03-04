#!/bin/sh

#
# cat data/data/com.zattoo.player/shared_prefs/zattoo.prefs.xml
#

#
# Get recent version of patch to be injected.
#

#
# 1. Stop golang webbox process.
# 2. Do a fresh debug build of de.kappa.tvbox.apk in Android-Studio
#

cd ~/zattoo

cp ~/go/src/github.com/dezi/project.java.tvbox/app/build/outputs/apk/debug/app-debug.apk ./de.kappa.tvbox.apk

rm -rf de.kappa.tvbox

apktool if de.kappa.tvbox.apk
apktool d de.kappa.tvbox.apk

rm -rf ./patch
cp -rp ./de.kappa.tvbox/smali_classes22/patch .

#
# Get a recent version of zattoo.apk
#

cd ~/zattoo

adb -s 192.168.178.31:5555 shell pm list packages -f | grep zattoo

adb -s 192.168.178.31:5555 pull /data/app/~~xvukfH4Lvy5oVFVvJcTn3w==/com.zattoo.player-7yqbj7N1IFpko8CUfito-Q==/base.apk ./com.zattoo.player.orignal.apk

rm -rf com.zattoo.player

apktool if com.zattoo.player.apk
apktool d com.zattoo.player.apk

#
# Inject patch into zattoo
#

cd ~/zattoo

cp -rp ./patch ./com.zattoo.player/smali

#
# Repack and sign new apk.
#

cd ~/zattoo

apktool b com.zattoo.player --use-aapt2 -o com.zattoo.player.repacked.apk

~/Library/Android/sdk/build-tools/33.0.0/zipalign -v -p -f 4 com.zattoo.player.repacked.apk com.zattoo.player.aligned.apk

cp com.zattoo.player.aligned.apk com.zattoo.player.resigned.apk
~/Library/Android/sdk/build-tools/33.0.0/apksigner sign --ks ./release.keystore com.zattoo.player.resigned.apk << EOF
blabla
EOF

#
# Re-install zatto player.
#

adb connect 192.168.178.31:5555

adb -s 192.168.178.31:5555 shell settings put global verifier_verify_adb_installs 0
adb -s 192.168.178.31:5555 shell settings put global package_verifier_enable 0
# adb -s 192.168.178.31:5555 uninstall com.zattoo.player
adb -s 192.168.178.31:5555 install com.zattoo.player.resigned.apk









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
~/Library/Android/sdk/build-tools/33.0.0/apksigner sign --ks ./release.keystore com.zattoo.player.resigned.apk << EOF
blabla
EOF


