
cd ~/tv-apps/tp6

rm -rf com.yoyinprintera4.app

apktool if com.yoyinprintera4.app.apk
apktool d com.yoyinprintera4.app.apk






#####




cd ~/tv-apps/tp6
apktool b com.yoyinprintera4.app --use-aapt2 -o com.yoyinprintera4.app.repacked.apk

~/Library/Android/sdk/build-tools/33.0.0/zipalign -v -p -f 4 com.yoyinprintera4.app.repacked.apk com.yoyinprintera4.app.aligned.apk

cp com.yoyinprintera4.app.aligned.apk com.yoyinprintera4.app.resigned.apk
~/Library/Android/sdk/build-tools/33.0.0/apksigner sign --ks ../release.keystore com.yoyinprintera4.app.resigned.apk << EOF
blabla
EOF

adb connect 8B3X136F0
adb -s 8B3X136F0 install -r com.yoyinprintera4.app.resigned.apk
