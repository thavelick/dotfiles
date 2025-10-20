#!/bin/bash
set -e

# Download and install neovim AppImage (latest stable release)
NVIM_APPIMAGE="/tmp/nvim-linux-x86_64.appimage"

# Determine if we need sudo (use sudo if not already root)
SUDO=""
if [ "$EUID" -ne 0 ]; then
  SUDO="sudo"
fi

echo "Installing neovim (latest stable)..."

# Download AppImage from stable tag (always latest stable release)
curl -L "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage" -o "$NVIM_APPIMAGE"
chmod +x "$NVIM_APPIMAGE"

# Extract and install
cd /tmp
"$NVIM_APPIMAGE" --appimage-extract > /dev/null
$SUDO mv squashfs-root/usr/bin/nvim /usr/local/bin/nvim
$SUDO mkdir -p /usr/local/share/nvim
$SUDO mv squashfs-root/usr/share/nvim/runtime /usr/local/share/nvim/

# Cleanup
rm -rf "$NVIM_APPIMAGE" squashfs-root

echo "neovim installed successfully"
nvim --version | head -3
