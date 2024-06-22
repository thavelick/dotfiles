#!/bin/bash
set -e
mkdir -p ~/.local/bin
ln -svf "$DOTFILES_HOME/tmux/project_sessions.sh" ~/.local/bin/project_sessions.sh
