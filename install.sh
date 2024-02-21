#!/bin/bash
export DOTFILES_HOME=$(pwd)
if [ $(uname) = 'Darwin' ]; then
  missing_packages=$(comm -13 <(cat <(brew ls --formula)  <(brew ls --cask) | sort) <(sort mac/packages))
  if [ -n "$missing_packages" ]; then
    # echo "missing: $missing_packages"

    brew install $missing_packages
  fi
elif grep -qF Raspbian /etc/issue; then
  sudo apt-get update
  sudo apt-get upgrade
  missing_packages=$(comm  -13 <(dpkg-query -f '${Package}\n' -W| sort) <(sort raspbian/packages))
  sudo apt-get install $missing_packages
  git/setup.sh
else # Assume Arch or derivaties
  sudo pacman -Syu
  missing_packages=$(comm  -13 <(pacman -Qq | sort) <(sort arch/packages))
  if ! pacman -Qq yay > /dev/null; then
    sudo pacman -S --needed git base-devel
    mkdir -p $HOME/src
    [[ -d $HOME/src/yay ]] && git clone https://aur.archlinux.org/yay.git ~/src/yay
    cd $HOME/src/yay
    makepkg -si
  fi

  if [ -n "$missing_packages" ]; then
    yay -S $missing_packages
  fi
  waybar/setup.sh
  river/setup.sh
  alacritty/setup.sh
  qutebrowser/setup.sh
  git/setup.sh
  nag_runner/setup.sh
  amfora/setup.sh
  neomutt/setup.sh
  fbterm/setup.sh
fi

vim/setup.sh
zsh/setup.sh
