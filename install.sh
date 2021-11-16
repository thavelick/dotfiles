#!/bin/sh
export DOTFILES_HOME=`pwd`
if grep -qF Arch /etc/issue; then
  missing_packages=`comm  -13 <(pacman -Qq | sort) <(sort arch/packages)`
  if ! pacman -Qq yay > /dev/null; then
    sudo pacman -S --needed git base-devel
    mkdir -p ~/src
    [[ -d ~/src/yay ]] && git clone https://aur.archlinux.org/yay.git ~/src/yay
    cd ~/src/yay
    makepkg -si
  fi 
  if [ -n $missing_packages ]; then 
    yay -S $missing_packages
  fi
fi


git/setup.sh
