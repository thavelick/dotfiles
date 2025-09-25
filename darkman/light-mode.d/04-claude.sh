#!/bin/bash
# Claude light theme - called by darkman at sunrise
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../theme-functions.sh"
set_claude_theme "light"
notify_claude_terminals "light" "43;30;1" "☀️"