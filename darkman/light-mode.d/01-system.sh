#!/bin/bash
# System light theme - called by darkman at sunrise
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$SCRIPT_DIR/../theme-functions.sh"
set_system_theme "light"