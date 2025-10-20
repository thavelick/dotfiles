#!/bin/sh
packer_path="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
[ ! -d "$packer_path" ] && mkdir -p "$packer_path" && git clone --depth 1 https://github.com/wbthomason/packer.nvim "$packer_path"
echo "$packer_path"

# symlink .config/nvim/init.vim
mkdir -p "$HOME/.config/nvim"
ln -svf "$DOTFILES_HOME/vim/init.lua" "$HOME/.config/nvim/init.lua"

# symlink .vim
ln -svf "$DOTFILES_HOME/vim/.vim" "$HOME"
#  symlink .vimrc
ln -svf "$DOTFILES_HOME/vim/vimrc" "$HOME/.vimrc"

# Run PackerSync to install plugins (wait for completion before exiting)
nvim --headless -c 'autocmd User PackerComplete quitall' +PackerSync 2>&1 || true
