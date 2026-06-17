#!/bin/bash
# Shared functions for darkman theme switching

# Set system theme via gsettings
set_system_theme() {
    local mode=$1
    gsettings set org.gnome.desktop.interface color-scheme "prefer-$mode"
    logger "Darkman: System switched to $mode theme"
}

# Set foot terminal theme and signal running instances
set_foot_theme() {
    local mode=$1
    local signal=$2
    local theme_config="$HOME/.local/share/foot/foot-theme.ini"

    # Update initial-color-theme setting
    if [[ "$mode" == "dark" ]]; then
        echo "initial-color-theme=dark" > "$theme_config"
    else
        echo "initial-color-theme=light" > "$theme_config"
    fi

    # Signal all running foot instances to reload config
    pkill -"$signal" -u "$(id -u)" foot
    logger "Darkman: Foot switched to $mode theme"
}

# Set zsh theme variables and signal running shells
set_zsh_theme() {
    local mode=$1

    # Signal running zsh shells to update theme
    pkill -USR1 -u "$(id -u)" zsh
    logger "Darkman: Zsh switched to $mode theme"
}