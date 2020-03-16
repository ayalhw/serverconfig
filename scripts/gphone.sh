#!/usr/bin/env bash

# don't forward for myself
# termite -t phone -e "adb shell -t su -c source /data/gentoo64/startprefix"
termite -t phone -e "ssh -t root@phone 'env -i TERM=\$TERM SSH_CONNECTION=\"\$SSH_CONNECTION\" /data/gentoo64/startprefix'"
