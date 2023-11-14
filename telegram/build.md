# TDLib Setup

### Important Note
```
MD-Format fucks up $ and \ in display. 

Fuck --- this --- shit. 

Go to source to copy command sequences.
```

### Basic Installs Linux
```
sudo apt install -y make zlib1g-dev libssl-dev 
sudo apt install -y gperf php-cli cmake g++
```

### Basic Installs OSX
```
brew install cmake
brew install openssl
brew install gperf
brew install daemonize

```

### Git Repository
```
mkdir -p /opt/box/gen
cd /opt/box/gen
rm -rf tdlib
mkdir tdlib
cd tdlib
git clone https://github.com/tdlib/td.git
cd td
git checkout tags/v1.8.0
```

### Compile for Dpkg-Collect (Linux)
```
cd /opt/box/gen/tdlib/td
rm -rf build
mkdir build
cd build
#cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=../tdlib -DTD_ENABLE_LTO=ON ..
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=../tdlib ..
cmake --build . --target install -j 1
cd ..
cd ..
ls -l td/tdlib
```

### Compile for Dpkg-Collect (Mac-OSX)
```
cd /opt/box/gen/tdlib/td
rm -rf build
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DOPENSSL_ROOT_DIR=/usr/local/opt/openssl/ -DCMAKE_INSTALL_PREFIX:PATH=../tdlib ..
cmake --build . --target install
cd ..
cd ..
ls -l td/tdlib
```

### Install into /usr/local
```
#
# Preserve symlinks of libs:
#
cd /usr/local
(cd /opt/box/gen/tdlib/td/tdlib; tar -cf - include lib) | sudo tar xvf -
sudo ldconfig
```
