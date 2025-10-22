#!/bin/bash
set -e

sudo apt update
sudo apt upgrade
missing_packages=$(comm -13 <(dpkg-query -f '${Package}\n' -W | sort) <(sort debian/packages))

if [ -n "$missing_packages" ]; then
  # shellcheck disable=SC2086
  sudo apt install $missing_packages
fi

"$DOTFILES_HOME"/dotfiles-bin/setup.sh
"$DOTFILES_HOME"/river/install.sh
"$DOTFILES_HOME"/river/setup.sh
"$DOTFILES_HOME"/amfora/setup.sh
"$DOTFILES_HOME"/font/setup.sh
"$DOTFILES_HOME"/foot/setup.sh
"$DOTFILES_HOME"/git/setup.sh
"$DOTFILES_HOME"/nag_runner/setup.sh
"$DOTFILES_HOME"/waybar/setup.sh
"$DOTFILES_HOME"/sfx/setup.sh
