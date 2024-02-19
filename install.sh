#!/bin/bash
set -e
DOTFILES_HOME=$(pwd)
export DOTFILES_HOME
if [ "$(uname)" = 'Darwin' ]; then
  missing_packages=$(comm -13 <(cat <(brew ls --formula)  <(brew ls --cask) | sort) <(sort mac/packages))
  if [ -n "$missing_packages" ]; then
    brew install "$missing_packages"
  fi
  amfora/setup.sh
elif grep -qF Raspbian /etc/issue; then
  sudo apt-get update
  sudo apt-get upgrade
  missing_packages=$(comm  -13 <(dpkg-query -f '${Package}\n' -W| sort) <(sort raspbian/packages))
  sudo apt-get install "$missing_packages"
  git/setup.sh
elif grep -qF Debian /etc/issue; then
  debian/install.sh
else # Assume Arch or derivatives
  sudo pacman -Syu
  missing_packages=$(comm  -13 <(pacman -Qq | sort) <(sort arch/packages))
  if ! pacman -Qq yay > /dev/null; then
    sudo pacman -S --needed git base-devel
    mkdir -p "$HOME/src"
    [[ -d $HOME/src/yay ]] && git clone https://aur.archlinux.org/yay.git ~/src/yay
    cd "$HOME/src/yay" || exit
    makepkg -si
  fi

  if [ -n "$missing_packages" ]; then
    yay -S "$missing_packages"
  fi
  dwm/setup.sh
  waybar/setup.sh
  river/setup.sh
  foot/setup.sh
  git/setup.sh
  nag_runner/setup.sh
  amfora/setup.sh
  neomutt/setup.sh
  fbterm/setup.sh
  font/setup.sh
  sway/setup.sh
  x11/setup.sh
fi

vim/setup.sh
zsh/setup.sh
