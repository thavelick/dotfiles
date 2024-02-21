#!/bin/bash
set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <percentage>"
    exit 1
fi

# The percentage change; positive to increase, negative to decrease
PERCENT_CHANGE=$1

BACKLIGHT_DEVICE="/sys/class/backlight/intel_backlight"

if [ ! -d "$BACKLIGHT_DEVICE" ]; then
    echo "Backlight device not found at $BACKLIGHT_DEVICE"
    exit 1
fi

MAX_BRIGHTNESS=$(cat "$BACKLIGHT_DEVICE/max_brightness")
CURRENT_BRIGHTNESS=$(cat "$BACKLIGHT_DEVICE/brightness")
DELTA=$(awk "BEGIN {print int(($MAX_BRIGHTNESS * $PERCENT_CHANGE) / 100)}")
NEW_BRIGHTNESS=$((CURRENT_BRIGHTNESS + DELTA))

if [ "$NEW_BRIGHTNESS" -lt 0 ]; then
    NEW_BRIGHTNESS=0
elif [ "$NEW_BRIGHTNESS" -gt "$MAX_BRIGHTNESS" ]; then
    NEW_BRIGHTNESS=$MAX_BRIGHTNESS
fi

echo "$NEW_BRIGHTNESS" | tee "$BACKLIGHT_DEVICE/brightness" > /dev/null
