#!/bin/sh

# install Vim-Plug for nvim
plug_vim_path=$HOME/.local/share/nvim/site/autoload/plug.vim
[ -f $plug_vim_path ] || curl -fLo $plug_vim_path --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


# symlink .config/nvim/init.vim
mkdir -p $HOME/.config/nvim
ln -svf $DOTFILES_HOME/vim/init.vim $HOME/.config/nvim/init.vim

# symlink .vim
ln -svf $DOTFILES_HOME/vim/.vim $HOME
#  symlink .vimrc
ln -svf $DOTFILES_HOME/vim/vimrc $HOME/.vimrc
