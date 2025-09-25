#!/bin/bash
# Claude dark theme - called by darkman at sunset
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$SCRIPT_DIR/../theme-functions.sh"
set_claude_theme "dark"
notify_claude_terminals "dark" "41;37;1" "🌙"