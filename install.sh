#!/bin/bash
set -e
DOTFILES_HOME=$(pwd)
export DOTFILES_HOME

# Parse command line arguments
NO_GUI=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --no-gui|--cli-only)
      NO_GUI=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--no-gui|--cli-only]"
      exit 1
      ;;
  esac
done
if [ "$(uname)" = 'Darwin' ]; then
  missing_packages=$(comm -13 <(cat <(brew ls --formula)  <(brew ls --cask) | sort) <(sort mac/packages))
  if [ -n "$missing_packages" ]; then
    brew install "$missing_packages"
  fi
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
  
  # Choose package list based on GUI flag
  if [ "$NO_GUI" = true ]; then
    missing_packages=$(comm  -13 <(pacman -Qq | sort) <(sort arch/packages-cli))
  else
    missing_packages=$(comm  -13 <(pacman -Qq | sort) <(sort <(cat arch/packages-gui arch/packages-cli)))
  fi
  
  if ! pacman -Qq yay > /dev/null; then
    echo "yay block"
    sudo pacman -S --needed git base-devel
    mkdir -p "$HOME/src"
    [[ -d $HOME/src/yay ]] || git clone https://aur.archlinux.org/yay.git ~/src/yay
    cd "$HOME/src/yay" || exit
    makepkg -si --noconfirm
  fi

  if [ -n "$missing_packages" ]; then
    for pkg in $missing_packages; do
      yay -S --noconfirm "$pkg"
    done
  fi
  
  # Run setup scripts based on GUI flag
  if [ "$NO_GUI" = false ]; then
    waybar/setup.sh
    river/setup.sh
    foot/setup.sh
    font/setup.sh
  fi
  
  git/setup.sh
  nag_runner/setup.sh
  amfora/setup.sh
  tidy/setup.sh
  tmux/setup.sh
fi

vim/setup.sh
zsh/setup.sh
