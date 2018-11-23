#!/usr/bin/env bash

if ! pgrep -f 'release/app/scrcpy' > /dev/null
then
    cd /home/amos/git/scrcpy/
    ./run release &
    sleep 0.5
fi

workspace=$(bspc query -D -d focused --names)

id=$(cat /tmp/scrcpy)
if [[ -z "$id" ]]
then
    exit 0
fi

if bspc query -N -d focused | grep -q "$(bspc query -N -n "$id")"
then
    bspc node "$id" -g hidden -f
else
    bspc node "$id" --to-desktop "$workspace"
    bspc node "$id" -g hidden=off -f
    bspc node "$id" -t floating
    bspc node "$id" -l above
fi

wh=($(xdpyinfo | grep dimensions | sed -r '/^[^0-9]*([0-9]+)x([0-9]+).*/!d;s//\1 \2/;q'))

xy=($(xwininfo -id $id | grep dimensions | sed -r '/^[^0-9]*([0-9]+)x([0-9]+).*/!d;s//\1 \2/;q'))
# w=${wh[0]}
# h=${wh[1]}
# x=$((w/4 + 230))
# y=30
# w=$((w/2))
# h=$((h - 60))
# xdo move -x $x -y $y "$id"
# xdo resize -w $w -h $h "$id"
