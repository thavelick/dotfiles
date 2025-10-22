#!/bin/bash
set -e

DOTFILES_HOME=${DOTFILES_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}

# Create symlink from ~/dotfiles-bin to the bin directory
ln -sf "$DOTFILES_HOME/bin" "$HOME/dotfiles-bin"

echo "✓ Symlinked ~/dotfiles-bin to $DOTFILES_HOME/bin"
