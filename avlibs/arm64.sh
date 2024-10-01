#!/bin/bash

#
# Collect ffmpeg libs for arm64.
#

scp /usr/lib/aarch64-linux-gnu/libavcodec.so.58 dennis-mb:/opt/box/gen/avlibs/aarch64-linux-gnu
scp /usr/lib/aarch64-linux-gnu/libavutil.so.56 dennis-mb:/opt/box/gen/avlibs/aarch64-linux-gnu
scp /usr/lib/aarch64-linux-gnu/libswscale.so.5 dennis-mb:/opt/box/gen/avlibs/aarch64-linux-gnu
scp /usr/lib/aarch64-linux-gnu/libswresample.so.3 dennis-mb:/opt/box/gen/avlibs/aarch64-linux-gnu
scp /usr/lib/aarch64-linux-gnu/libvpx.so.7 dennis-mb:/opt/box/gen/avlibs/aarch64-linux-gnu
scp /usr/lib/aarch64-linux-gnu/libdav1d.so.5 dennis-mb:/opt/box/gen/avlibs/aarch64-linux-gnu
scp /usr/lib/aarch64-linux-gnu/libcodec2.so.1.0 dennis-mb:/opt/box/gen/avlibs/aarch64-linux-gnu
scp /usr/lib/aarch64-linux-gnu/libx264.so.163 dennis-mb:/opt/box/gen/avlibs/aarch64-linux-gnu
#scp /usr/lib/aarch64-linux-gnu/libmfx.so.1 dennis-mb:/opt/box/gen/avlibs/aarch64-linux-gnu