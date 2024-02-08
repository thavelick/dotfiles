#!/bin/bash
program_to_launch=$(echo -n "$PATH" | xargs -d: -I{} -r find -L {} -maxdepth 1 -mindepth 1 -type f -executable -printf '%P\n' 2>/dev/null | sort -u | fzf)
desktop_file=$(grep -lE "Exec=.*$program_to_launch" /usr/share/applications/*.desktop)

[ -z "$desktop_file" ] || grep -qE "Terminal=true" "$desktop_file" && program_to_launch="foot $(which "$program_to_launch")"
riverctl spawn "$program_to_launch"
