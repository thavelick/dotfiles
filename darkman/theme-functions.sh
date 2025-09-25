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
                    printf '\033[%sm                                                           \033[0m\n' "$color_code"
                    printf '\033[%sm  %s DARKMAN: Switched to %s theme - Restart Claude!   \033[0m\n' "$color_code" "$emoji" "${mode^^}"
                    printf '\033[%sm                                                           \033[0m\n' "$color_code"
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
    local theme_config="$HOME/.local/share/foot/foot-theme.ini"

    # Update initial-color-theme setting (1=dark/colors, 2=light/colors2)
    if [[ "$mode" == "dark" ]]; then
        echo "initial-color-theme=1" > "$theme_config"
    else
        echo "initial-color-theme=2" > "$theme_config"
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

# Set Claude theme config
set_claude_theme() {
    local mode=$1

    "$HOME/.claude/local/claude" config set -g theme "$mode"
    logger "Darkman: Claude switched to $mode theme"
}