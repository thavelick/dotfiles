#!/bin/bash
set -e
# Use environment variable if set, otherwise use current directory
DOTFILES_HOME=${DOTFILES_HOME:-$(pwd)}
export DOTFILES_HOME

# Parse command line arguments
NO_GUI=false
CORE_ONLY=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --no-gui|--cli-only)
      NO_GUI=true
      shift
      ;;
    --core)
      CORE_ONLY=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--no-gui|--cli-only] [--core]"
      exit 1
      ;;
  esac
done
if [ "$(uname)" = 'Darwin' ]; then
  mac/install.sh
elif grep -qF Debian /etc/issue; then
  debian/install.sh
else # Assume Arch or derivatives
  sudo pacman -Syu --noconfirm
  
  if ! pacman -Qq yay-bin > /dev/null 2>&1 && ! pacman -Qq yay > /dev/null 2>&1; then
    echo "yay block"
    sudo pacman -S --needed --noconfirm git base-devel
    mkdir -p "$HOME/src"
    [[ -d $HOME/src/yay-bin ]] || git clone --branch yay-bin --single-branch https://github.com/archlinux/aur.git ~/src/yay-bin
    cd "$HOME/src/yay-bin" || exit
    makepkg -si --noconfirm
    cd "$DOTFILES_HOME" || exit
  fi

  # Choose package list based on flags
  if [ "$CORE_ONLY" = true ]; then
    missing_packages=$(comm  -13 <(pacman -Qq | sort) <(sort arch/packages-core))
  elif [ "$NO_GUI" = true ]; then
    missing_packages=$(comm  -13 <(pacman -Qq | sort) <(sort arch/packages-cli))
  else
    missing_packages=$(comm  -13 <(pacman -Qq | sort) <(sort <(cat arch/packages-gui arch/packages-cli)))
  fi

  if [ -n "$missing_packages" ]; then
    for pkg in $missing_packages; do
      yay -S --noconfirm "$pkg"
    done
  fi
  
  # Run setup scripts based on GUI flag
  if [ "$NO_GUI" = false ] && [ "$CORE_ONLY" = false ]; then
    "$DOTFILES_HOME"/waybar/setup.sh
    "$DOTFILES_HOME"/river/setup.sh
    "$DOTFILES_HOME"/foot/setup.sh
    "$DOTFILES_HOME"/font/setup.sh
    "$DOTFILES_HOME"/systemd/setup.sh
  fi
  
  "$DOTFILES_HOME"/git/setup.sh
  "$DOTFILES_HOME"/nag_runner/setup.sh
  "$DOTFILES_HOME"/amfora/setup.sh
  "$DOTFILES_HOME"/tidy/setup.sh
  "$DOTFILES_HOME"/tmux/setup.sh
fi

"$DOTFILES_HOME"/vim/setup.sh
"$DOTFILES_HOME"/zsh/setup.sh
