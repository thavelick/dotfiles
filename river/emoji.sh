#!/bin/bash
set -e
line_picked=$(fzf < ~/.local/share/unicode-map.txt)
character_picked=$(echo "$line_picked" | awk '{print $1}')
wl-copy "$character_picked"
