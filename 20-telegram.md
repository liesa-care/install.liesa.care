## Compile Telegram Go

### Telegram Tdlib Repository
```
cd ~/go/src/github.com
mkdir zelenin
cd zelenin
git clone https://github.com/zelenin/go-tdlib.git

#
# Tdlib is linked statically by 
# default, which takes forever.
# Change to shared linking.
#
vi go-tdlib/client/tdjson_static.go
...
-// +build !libtdjson
+// +build libtdjson
...

vi go-tdlib/client/tdjson_dynamic.go
...
-// +build libtdjson
+// +build !libtdjson
...
```
