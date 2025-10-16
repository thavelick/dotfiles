#!/bin/bash
set -e

# Check if npm prefix is writable by current user
npm_prefix=$(npm config get prefix)
if [ ! -w "$npm_prefix" ]; then
  # Prefix is not writable, reconfigure to user home directory
  user_npm_dir="$HOME/.npm-global"
  mkdir -p "$user_npm_dir"
  npm config set prefix "$user_npm_dir"
  npm_prefix="$user_npm_dir"
fi

missing_packages=$(comm -13 <(npm list -g --depth=0 --json 2>/dev/null | jq -r '.dependencies | keys | .[]' 2>/dev/null | sort) <(sort "$DOTFILES_HOME/npm/packages"))
if [ -n "$missing_packages" ]; then
  for pkg in $missing_packages; do
    npm install -g "$pkg"
  done
fi
