#!/bin/bash
# Shared functions for darkman theme switching

# Notify Claude terminals with colored bar at top
# Usage: notify_claude_terminals "dark" "41;37;1" "🌙"
notify_claude_terminals() {
    local mode=$1
    local color_code=$2
    local emoji=$3

    for pid in $(pgrep -f "claude" 2>/dev/null || true); do
        if [[ -d "/proc/$pid" ]]; then
            tty=$(ps -p "$pid" -o tty= 2>/dev/null | tr -d ' ' || echo "unknown")
            if [[ "$tty" != "unknown" && "$tty" != "?" && -e "/dev/$tty" ]]; then
                # Show prominent notification bar at top
                {
                    printf '\033[s'      # Save cursor position
                    printf '\033[H'      # Move cursor to top-left
                    printf "\033[${color_code}m                                                           \033[0m\n"
                    printf "\033[${color_code}m  $emoji DARKMAN: Switched to ${mode^^} theme - Restart Claude!   \033[0m\n"
                    printf "\033[${color_code}m                                                           \033[0m\n"
                    printf '\033[u'      # Restore cursor position
                } > "/dev/$tty"
            fi
        fi
    done
}

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

    CONFIG_FILE="$HOME/.config/foot/foot.ini"

    # Set initial color theme based on mode
    local theme_num
    if [[ "$mode" == "dark" ]]; then
        theme_num=1
    else
        theme_num=2
    fi

    if grep -q "^initial-color-theme=" "$CONFIG_FILE"; then
        sed -i "s/^initial-color-theme=.*/initial-color-theme=$theme_num/" "$CONFIG_FILE"
    else
        # Add initial-color-theme setting under [main] section
        sed -i '/^\[main\]/a initial-color-theme='"$theme_num" "$CONFIG_FILE"
    fi

    # Signal all running foot instances
    pkill -"$signal" -u "$(id -u)" foot

    logger "Darkman: Foot switched to $mode theme"
}

# Set zsh theme variables and signal running shells
set_zsh_theme() {
    local mode=$1

    # Set theme environment variable
    echo "export THEME_MODE=\"$mode\"" > /tmp/theme_mode_env

    # Signal running zsh shells to update theme
    pkill -USR1 -u "$(id -u)" zsh

    logger "Darkman: Zsh switched to $mode theme"
}

# Set Claude theme config
set_claude_theme() {
    local mode=$1

    "$HOME/.claude/local/claude" config set -g theme "$mode"
    logger "Darkman: Claude switched to $mode theme"
}