#!/bin/bash
# Foot light theme - called by darkman at sunrise
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "$SCRIPT_DIR/../theme-functions.sh"
set_foot_theme "light" "USR2"