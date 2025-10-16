#!/bin/bash
set -e

# Parse command line arguments
CORE_ONLY=false
NO_GUI=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --core)
      CORE_ONLY=true
      shift
      ;;
    --no-gui|--cli-only)
      NO_GUI=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--core] [--no-gui|--cli-only]"
      exit 1
      ;;
  esac
done

# Determine script directory for finding package files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# System update
sudo pacman -Syu --noconfirm

# Install yay-bin if not already installed
if ! pacman -Qq yay-bin > /dev/null 2>&1 && ! pacman -Qq yay > /dev/null 2>&1; then
  echo "Installing yay-bin..."
  sudo pacman -S --needed --noconfirm git base-devel
  mkdir -p "$HOME/src"
  [[ -d $HOME/src/yay-bin ]] || git clone --branch yay-bin --single-branch https://github.com/archlinux/aur.git ~/src/yay-bin
  cd "$HOME/src/yay-bin" || exit
  makepkg -si --noconfirm
  cd - > /dev/null || exit
fi

# Choose package list based on flags
if [ "$CORE_ONLY" = true ]; then
  missing_packages=$(comm -13 <(pacman -Qq | sort) <(sort "$SCRIPT_DIR/packages-core"))
elif [ "$NO_GUI" = true ]; then
  missing_packages=$(comm -13 <(pacman -Qq | sort) <(sort "$SCRIPT_DIR/packages-cli"))
else
  missing_packages=$(comm -13 <(pacman -Qq | sort) <(sort <(cat "$SCRIPT_DIR/packages-gui" "$SCRIPT_DIR/packages-cli")))
fi

# Install missing packages
if [ -n "$missing_packages" ]; then
  for pkg in $missing_packages; do
    yay -S --noconfirm "$pkg"
  done
fi

echo "Package installation complete!"

# Setup npm and uv packages
export DOTFILES_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -f "$DOTFILES_HOME/npm/setup.sh" ]; then
  echo "Setting up npm packages..."
  bash "$DOTFILES_HOME/npm/setup.sh"
fi

if [ -f "$DOTFILES_HOME/uv/setup.sh" ]; then
  echo "Setting up uv tools..."
  bash "$DOTFILES_HOME/uv/setup.sh"
fi

echo "All setup complete!"
