#!/bin/sh

# symlink .vim
ln -svf $DOTFILES_HOME/vim/.vim $HOME
#  symlink .vimrc
ln -svf $DOTFILES_HOME/vim/vimrc $HOME/.vimrc
