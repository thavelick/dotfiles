#!/bin/bash
set -e
mkdir -p ~/.local/bin
mkdir -p ~/.config/tmux
ln -svf "$DOTFILES_HOME/tmux/project_sessions.sh" ~/.local/bin/project_sessions.sh
ln -svf "$DOTFILES_HOME/tmux/tmux.conf" ~/.config/tmux/tmux.conf
