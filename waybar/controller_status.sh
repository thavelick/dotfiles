#!/bin/bash

# Waybar Nintendo Switch Pro Controller module

# Check if controller is connected
if bluetoothctl info 64:B5:C6:3E:91:54 2>/dev/null | grep -q "Connected: yes"; then
    # Controller is connected via Bluetooth

    # Check battery status
    battery_path=$(find /sys/class/power_supply -name "*nintendo_switch_controller*" 2>/dev/null | head -1)

    if [ -n "$battery_path" ]; then
        if [ -f "$battery_path/capacity_level" ]; then
            capacity_level=$(cat "$battery_path/capacity_level")
        else
            capacity_level="Unknown"
        fi

        if [ -f "$battery_path/status" ]; then
            battery_status=$(cat "$battery_path/status")
        else
            battery_status="Unknown"
        fi

        # Choose battery percentage based on level
        case $capacity_level in
            "Full") battery_icon="" && battery_percent="100";;
            "High") battery_icon="" && battery_percent="80";;
            "Normal") battery_icon=" " && battery_percent="40";;
            "Low") battery_icon="" && battery_percent="20";;
            "Critical") battery_icon="" && battery_percent="10";;
            *) battery_icon="" && battery_percent="0";;
        esac

        if [ "$battery_status" = "Charging" ]; then
            charging_icon="🗲"
            echo "  ${charging_icon} ${battery_icon} ${battery_percent}%"
        else
            echo "  ${battery_icon} ${battery_percent}%"
        fi

    else
        # Connected but no battery info (probably USB)
        if lsusb | grep -q Nintendo; then
            echo "🎮  100%"  # USB charging - assume full
        else
            echo "🎮  ?"  # Bluetooth connected but no battery info
        fi
    fi
else
    # Controller not connected
    echo ""
fi
