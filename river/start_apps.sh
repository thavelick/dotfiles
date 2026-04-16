#!/bin/sh
# Start common apps on their designated tags at login.
# Rules are added pre-spawn, then removed after a wait long enough for every
# window to have mapped — so only the startup windows get routed and later
# launches of the same apps aren't stuck to these tags.
#
# Waybar tag icons:
#   1 🖥️ — foot (primary terminal)
#   2 🌐 — zen-browser
#   4 🔐 — keepassxc

riverctl rule-add -app-id foot      tags $((1 << 0))
riverctl rule-add -app-id zen       tags $((1 << 1))
riverctl rule-add -app-id org.keepassxc.KeePassXC tags $((1 << 3))

riverctl spawn foot
riverctl spawn keepassxc
riverctl spawn zen-browser

# Wait long enough for the slowest window to map before tearing down rules.
sleep 5

riverctl rule-del -app-id foot      tags
riverctl rule-del -app-id zen       tags
riverctl rule-del -app-id org.keepassxc.KeePassXC tags
