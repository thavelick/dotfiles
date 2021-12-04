#!/bin/sh

zsh_plugins_path=$HOME/.zsh
mkdir -p $zsh_plugins_path

# install p10k
p10k_path=$zsh_plugins_path/powerlevel10k
[ ! -d $p10k_path ] && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $p10k_path

# symlink .zshrc
ln -svf $DOTFILES_HOME/zsh/zshrc $HOME/.zshrc

# symlink .p10k.zsh
ln -svf $DOTFILES_HOME/zsh/p10k.zsh $HOME/.p10k.zsh
