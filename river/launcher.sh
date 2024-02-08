#!/bin/bash
program_to_launch=$(echo -n "$PATH" | xargs -d: -I{} -r find -L {} -maxdepth 1 -mindepth 1 -type f -executable -printf '%P\n' 2>/dev/null | sort -u | fzf)
package=$(pkgfile -qb "$(which "$program_to_launch")" 2>/dev/null)
dependencies=$(pacman -Qi "$package" 2>/dev/null | grep -oP 'Depends On.*' | cut -d: -f2)
# If the program does NOT depend on a gui package, launch it with foot:
if ! echo "$dependencies" | grep -qE 'gtk3|qt5|qt6|wayland'; then
  program_to_launch="foot -- $(which "$program_to_launch")"
fi
riverctl spawn "$program_to_launch"
