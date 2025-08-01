#!/bin/sh

zsh_plugins_path=$HOME/.zsh
mkdir -p "$zsh_plugins_path"


# install syntax highlighting
syntax_highlight_path=$zsh_plugins_path/zsh-syntax-highlighting
[ ! -d "$syntax_highlight_path" ] && \
	git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
	"$syntax_highlight_path"

# install autosuggestions
suggestions_path=$zsh_plugins_path/zsh-autosuggestions
[ ! -d "$suggestions_path" ] && \
	git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git \
	"$suggestions_path"

# symlink .zshrc
ln -svf "$DOTFILES_HOME"/zsh/zshrc "$HOME"/.zshrc
