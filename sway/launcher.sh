#!/bin/bash
# get a list of all the programs in the PATH
programs=$(echo -n "$PATH" | xargs -d: -I{} -r find -L {} -maxdepth 1 -mindepth 1 -type f -executable -printf '%P\n' 2>/dev/null | sort -u)
# get the programs we've previously run, excluding any that don't exist anymore
programs_from_history=$(grep -xFf <(echo -e "$programs") "$HOME/.cache/launcher_history" 2>/dev/null)
# make a list of all the programs, sorted by the frequency they've been run via this launcher
frequency_sorted_programs=$(echo -e "$programs\n$programs_from_history" | sort | uniq -c | sort -nr | awk '{print $2}')

# let the user choose what to launch, saving what they choose to a history file for later runs
program_to_launch=$(echo -e "$frequency_sorted_programs" | fzf)
# exit if they didn't choose anything valid
[ -z "$program_to_launch" ] && exit 1
echo "$program_to_launch" >> "$HOME/.cache/launcher_history"

# run the program they chose, in a terminal if needed
desktop_file=$(grep -lE "Exec=.*$program_to_launch" /usr/share/applications/*.desktop)
[ -z "$desktop_file" ] || grep -qE "Terminal=true" "$desktop_file" && program_to_launch="foot $(which "$program_to_launch")"
swaymsg exec "$program_to_launch"

# set $menu dmenu_path | dmenu | xargs swaymsg exec --
