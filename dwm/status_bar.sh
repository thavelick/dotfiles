#!/bin/bash
set -e

trim_string() {
    # Usage: trim_string "   example   string    "

    # Remove all leading white-space.
    # '${1%%[![:space:]]*}': Strip everything but leading white-space.
    # '${1#${XXX}}': Remove the white-space from the start of the string.
    trim=${1#"${1%%[![:space:]]*}"}

    # Remove all trailing white-space.
    # '${trim##*[![:space:]]}': Strip everything but trailing white-space.
    # '${trim%${XXX}}': Remove the white-space from the end of the string.
    trim=${trim%"${trim##*[![:space:]]}"}

    printf '%s\n' "${trim}"
}

while true; do
    upower_output=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep percentage: | cut -f2 -d ":")
    battery_percent=$(trim_string "$upower_output")
    clock="$(date +'%a %I:%M %p %m-%d')"
    cpu="$(top -bn1 | grep Cpu | awk '{print $2}')"
    mem="$(free -h | awk '/^Mem/ {print $3 "/" $2}')"
    disk="$(df -h | awk '/^\/dev\/nvme0n1p2/ {print $3 "/" $2}')"
    max_brightness="$(cat /sys/class/backlight/intel_backlight/max_brightness)"
    brightness="$(cat /sys/class/backlight/intel_backlight/brightness)"
    brightness_percent=$((brightness * 100 / max_brightness))
    volume="$(amixer get Master | tail -n1 | sed -r 's/.*\[(.*)%\].*/\1/')"
    if amixer get Master | grep -q off; then
        volume="Mute"
    fi
status_text="${clock} | 🔋${battery_percent} | 🔊 ${volume} | 💻 ${cpu} | 📊 ${mem} | 🗄️: ${disk} | 💡 ${brightness_percent}%"
    xsetroot -name "${status_text}"
    sleep 60
done
