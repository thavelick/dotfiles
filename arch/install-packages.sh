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

# Make sure we can build the custom PKGBUILDs
sudo pacman -S --needed --noconfirm git base-devel

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
  # shellcheck disable=SC2086  # word-splitting is intended: install all at once
  sudo pacman -S --needed --noconfirm $missing_packages
fi

# Build and install custom PKGBUILDs (slack, zen, brother driver, zmx, ...)
echo "Installing custom PKGBUILDs..."
bash "$SCRIPT_DIR/pkgbuilds/install.sh"

echo "Package installation complete!"

# Setup npm and uv packages
DOTFILES_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" || exit
export DOTFILES_HOME

if [ -f "$DOTFILES_HOME/npm/setup.sh" ]; then
  echo "Setting up npm packages..."
  bash "$DOTFILES_HOME/npm/setup.sh"
fi

if [ -f "$DOTFILES_HOME/uv/setup.sh" ]; then
  echo "Setting up uv tools..."
  bash "$DOTFILES_HOME/uv/setup.sh"
fi

echo "All setup complete!"
