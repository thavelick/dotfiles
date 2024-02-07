#!/bin/bash
program_to_launch=$(echo -n "$PATH" | xargs -d: -I{} -r find -L {} -maxdepth 1 -mindepth 1 -type f -executable -printf '%P\n' 2>/dev/null | sort -u | fzf)
riverctl spawn "$program_to_launch"
