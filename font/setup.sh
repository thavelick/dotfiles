#!/bin/bash
set -e

mkdir -p ~/.local/share
[ ! -d ~/.local/share/fonts ] && ln -svfn "$DOTFILES_HOME/font/fonts" ~/.local/share/fonts
[ ! -d ~/.config/fontconfig ] && ln -svfn "$DOTFILES_HOME/font/fontconfig" ~/.config/fontconfig
exit 0
