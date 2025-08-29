#!/bin/sh
# Monitor hotplug daemon - polls DRM status files for changes

# Set DOTFILES_HOME if not already set
DOTFILES_HOME="${DOTFILES_HOME:-$HOME/Projects/dotfiles}"

prev=$(cat /sys/class/drm/*/status 2>/dev/null | sort)
while true; do
    sleep 2
    curr=$(cat /sys/class/drm/*/status 2>/dev/null | sort)
    if [ "$curr" != "$prev" ]; then
        "$DOTFILES_HOME/river/monitor-setup.sh"
    fi
    prev="$curr"
done