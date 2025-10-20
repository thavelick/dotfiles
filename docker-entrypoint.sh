#!/bin/bash
set -e

# Setup symlinks
ln -sf "$DOTFILES_HOME/zsh/zshrc" ~/.zshrc

# Setup vim
"$DOTFILES_HOME/vim/setup.sh"

# If a command was provided, run it. Otherwise start an interactive shell
if [ $# -gt 0 ]; then
    exec "$@"
else
    exec /bin/zsh -l
fi
