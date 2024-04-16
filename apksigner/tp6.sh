
cd ~/tv-apps/tp6

mv ~/go/src/github.com/dezi/project.java.tvbox/app/build/outputs/apk/debug/app-debug.apk ./de.kappa.tvbox.apk

rm -rf de.kappa.tvbox

apktool if de.kappa.tvbox.apk
apktool d de.kappa.tvbox.apk

rm -rf ./patch
cp -rp ./de.kappa.tvbox/smali_classes22/patch .








cd ~/tv-apps/tp6

rm -rf com.yoyinprintera4.app

apktool if com.yoyinprintera4.app.apk
apktool d com.yoyinprintera4.app.apk




cp -rp ./patch ./com.yoyinprintera4.app/smali


vi ./com.yoyinprintera4.app/smali_classes3/com/printer/PrinterManager\$PrintRunnable.smali
vi ./com.yoyinprintera4.app/smali_classes3/com/printer/PrinterManager\$ConnectRunnable.smali

#####




cd ~/tv-apps/tp6
apktool b com.yoyinprintera4.app --use-aapt2 -o com.yoyinprintera4.app.repacked.apk

~/Library/Android/sdk/build-tools/33.0.0/zipalign -v -p -f 4 com.yoyinprintera4.app.repacked.apk com.yoyinprintera4.app.aligned.apk

cp com.yoyinprintera4.app.aligned.apk com.yoyinprintera4.app.resigned.apk
~/Library/Android/sdk/build-tools/33.0.0/apksigner sign --ks ../release.keystore com.yoyinprintera4.app.resigned.apk << EOF
blabla
EOF

adb -s 8B3X136F0 install com.yoyinprintera4.app.resigned.apk
