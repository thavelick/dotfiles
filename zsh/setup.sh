#!/bin/sh

zsh_plugins_path=$HOME/.zsh
mkdir -p $zsh_plugins_path

# Make the cache folder for history
mkdir -p "$HOME/.cache/zsh"

# install p10k
p10k_path=$zsh_plugins_path/powerlevel10k
[ ! -d $p10k_path ] && \
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $p10k_path

# install syntax highlighting
syntax_highlight_path=$zsh_plugins_path/zsh-syntax-highlighting
[ ! -d $syntax_highlight_path ] && \
	git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
	$syntax_highlight_path

# symlink .zshrc
ln -svf $DOTFILES_HOME/zsh/zshrc $HOME/.zshrc

# symlink .p10k.zsh
ln -svf $DOTFILES_HOME/zsh/p10k.zsh $HOME/.p10k.zsh
