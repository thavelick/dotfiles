#!/bin/bash
set -e

missing_packages=$(comm -13 <(npm list -g --depth=0 --json | jq -r '.dependencies | keys | .[]' | sort) <(sort "$DOTFILES_HOME/npm/packages"))
if [ -n "$missing_packages" ]; then
  for pkg in $missing_packages; do
    npm install -g "$pkg"
  done
fi
