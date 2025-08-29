#!/bin/sh
set -e
# Monitor configuration for River window manager

LOGFILE="$HOME/.local/share/monitor-hotplug.log"
mkdir -p "$(dirname "$LOGFILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOGFILE"
}

log "Monitor setup triggered"

# Apply HiDPI scaling if HIDPI environment variable is set
if [ -n "$HIDPI" ]; then
    log "Applying HiDPI scaling to eDP-1"
    wlr-randr --output eDP-1 --scale 1.75
fi

# Configure second monitor scaling and position
if wlr-randr | grep -q "HDMI-A-1"; then
    log "HDMI-A-1 detected, configuring dual monitor setup"
    wlr-randr --output HDMI-A-1 --scale 1.75 --pos 0,0
    wlr-randr --output eDP-1 --pos 2194,0
else
    log "No HDMI-A-1 detected, configuring single monitor setup"
    wlr-randr --output eDP-1 --pos 0,0
fi

log "Monitor setup completed"