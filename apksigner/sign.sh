
keytool -genkey -v -keystore release.keystore -alias example -keyalg RSA -keysize 2048 -validity 10000

~/Library/Android/sdk/build-tools/33.0.0/apksigner sign --ks release.keystore copy.tv.accedo.xdk.dtag.production.apk
~/Library/Android/sdk/build-tools/33.0.0/apksigner sign --ks release.keystore copy.com.zattoo.player.neu

