#!/bin/bash
# Consolidated light theme switching - called by darkman at sunrise
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../theme-functions.sh"

# Switch all themes to light mode
set_system_theme "light"
set_foot_theme "light" "USR2"
set_zsh_theme "light"
set_claude_theme "light"
notify_claude_terminals "light" "43;30;1" "☀️"