#!/bin/sh

# Create chawan config directory and symlink config
mkdir -p "$HOME/.config/chawan"
ln -svf "$DOTFILES_HOME/chawan/config.toml" "$HOME/.config/chawan/config.toml"
ln -svf "$DOTFILES_HOME/chawan/auto.mailcap" "$HOME/.config/chawan/auto.mailcap"
