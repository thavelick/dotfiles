#!/bin/bash
set -e

missing_packages=$(comm -13 <(cat <(brew ls --formula)  <(brew ls --cask) | sort) <(sort "$DOTFILES_HOME/mac/packages"))
if [ -n "$missing_packages" ]; then
  for pkg in $missing_packages; do
    brew install "$pkg"
  done
fi

"$DOTFILES_HOME"/mac/setup.sh
"$DOTFILES_HOME"/git/setup.sh
"$DOTFILES_HOME"/tmux/setup.sh
