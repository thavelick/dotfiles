#!/bin/bash
# Consolidated dark theme switching - called by darkman at sunset
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../theme-functions.sh"

# Switch all themes to dark mode
set_system_theme "dark"
set_foot_theme "dark" "USR1"
set_zsh_theme "dark"
set_claude_theme "dark"
notify_claude_terminals "dark" "43;37;1" "🌙"