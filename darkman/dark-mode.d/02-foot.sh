#!/bin/bash
# Foot dark theme - called by darkman at sunset
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../theme-functions.sh"
set_foot_theme "dark" "USR1"