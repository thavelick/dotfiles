#!/bin/bash
set -e

mkdir -p "$HOME/.npm-global"
ln -svf "$DOTFILES_HOME"/npm/npmrc "$HOME"/.npmrc

missing_packages=$(comm -13 <(npm list -g --depth=0 --json 2>/dev/null | jq -r '.dependencies | keys | .[]' 2>/dev/null | sort) <(sort "$DOTFILES_HOME/npm/packages"))
if [ -n "$missing_packages" ]; then
  for pkg in $missing_packages; do
    npm install -g "$pkg"
  done
fi
