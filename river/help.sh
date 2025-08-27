#!/bin/bash
# River keybinding help screen using glow

# Wait for window to finish resizing before detecting terminal width
sleep 0.1
glow --pager -w "$(tput cols)" "$DOTFILES_HOME/river/README.md"