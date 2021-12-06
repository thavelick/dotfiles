#!/bin/sh
/usr/sbin/waybar &
[ -f "$HOME/background.jpg" ] && /usr/sbin/swaybg --image "$HOME/background.jpg" &
exec <&-
