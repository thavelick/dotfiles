#!/bin/sh
# Spawn foot in the current directory saved by zsh

pwd_file="$HOME/.cache/zsh/current_pwd"

if [ -f "$pwd_file" ]; then
    cd "$(cat "$pwd_file")" && foot
else
    foot
fi
