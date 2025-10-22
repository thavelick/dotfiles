#!/bin/bash
set -e

DOTFILES_HOME=${DOTFILES_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

mkdir -p "$XDG_CONFIG_HOME/dotfiles-sfx"
cp "$DOTFILES_HOME/sfx"/*.ogg "$XDG_CONFIG_HOME/dotfiles-sfx/"

echo "✓ Installed sound effects to $XDG_CONFIG_HOME/dotfiles-sfx"
