#!/bin/bash
set -e

# Download and install neovim AppImage (v0.11.4)
NVIM_VERSION="0.11.4"
NVIM_APPIMAGE="/tmp/nvim-linux-x86_64.appimage"

# Determine if we need sudo (use sudo if not already root)
SUDO=""
if [ "$EUID" -ne 0 ]; then
  SUDO="sudo"
fi

echo "Installing neovim v${NVIM_VERSION}..."

# Download AppImage
curl -L "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-x86_64.appimage" -o "$NVIM_APPIMAGE"
chmod +x "$NVIM_APPIMAGE"

# Extract and install
cd /tmp
"$NVIM_APPIMAGE" --appimage-extract > /dev/null
$SUDO mv squashfs-root/usr/bin/nvim /usr/local/bin/nvim
$SUDO mkdir -p /usr/local/share/nvim
$SUDO mv squashfs-root/usr/share/nvim/runtime /usr/local/share/nvim/

# Cleanup
rm -rf "$NVIM_APPIMAGE" squashfs-root

echo "neovim v${NVIM_VERSION} installed successfully"
nvim --version | head -3
