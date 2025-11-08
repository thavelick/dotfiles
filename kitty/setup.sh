#!/bin/sh
mkdir -p "$HOME/.config/kitty"
ln -svf "$DOTFILES_HOME/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
ln -svf "$DOTFILES_HOME/kitty/dark-theme.auto.conf" "$HOME/.config/kitty/dark-theme.auto.conf"
ln -svf "$DOTFILES_HOME/kitty/light-theme.auto.conf" "$HOME/.config/kitty/light-theme.auto.conf"
