#!/bin/sh
mkdir -p "$HOME/.config/foot"
ln -svf "$DOTFILES_HOME/foot/foot.ini" "$HOME/.config/foot/foot.ini"
mkdir -p "$HOME/.local/share/foot"
ln -svnf "$DOTFILES_HOME/foot/themes/" "$HOME/.local/share/foot/themes"
