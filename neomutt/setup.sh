#!/bin/sh

# Make the cache folder for mail
mkdir -p "$HOME/.cache/mutt"

# symlink .neomuttrc
ln -svf $DOTFILES_HOME/neomutt/neomuttrc $HOME/.neomuttrc
