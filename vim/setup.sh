#!/bin/sh

# symlink .config/nvim/init.vim
mkdir -p "$HOME/.config/nvim"
ln -svf "$DOTFILES_HOME/vim/init.lua" "$HOME/.config/nvim/init.lua"

# symlink .vim
ln -svf "$DOTFILES_HOME/vim/.vim" "$HOME"
#  symlink .vimrc
ln -svf "$DOTFILES_HOME/vim/vimrc" "$HOME/.vimrc"
