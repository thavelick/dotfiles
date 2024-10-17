#!/bin/bash
# Choose a file from ~/Projects with fzf, then start or a attach a tmux session for it.
# Within tmux, cd to that project's directory and start

set -e

project=$(find ~/Projects -maxdepth 1 -type d | cut -d '/' -f5 | fzf)
[[ -z $project ]] && exit 0

tmux new-session -A -s "$project" -c "$HOME/Projects/$project"

