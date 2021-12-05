#!/bin/sh

dwl_path="$HOME/Projects/dwl"

[ ! -d $dwl_path ] git clone git@github.com:thavelick/dwl.git $dwl_path
cd $dwl_path && make && sudo make install

# symlink waybar config
ln -svf $DOTFILES_HOME/dwl/waybar $HOME/.config/waybar

# symlink dwl start script
ln -svf $DOTFILES_HOME/dwl/start-dwl $HOME/start-dwl


