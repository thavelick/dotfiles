#!/bin/bash
set -e

missing_tools=$(comm -13 <(uv tool list | awk '{print $1}' | sort) <(sort "$DOTFILES_HOME/uv/tools"))
if [ -n "$missing_tools" ]; then
  for tool in $missing_tools; do
    uv tool install "$tool"
  done
fi
