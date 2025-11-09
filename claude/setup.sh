#!/bin/sh
mkdir -p "$HOME/.claude"
ln -svf "$DOTFILES_HOME/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
rm -rf "$HOME/.claude/commands"
ln -svf "$DOTFILES_HOME/claude/commands" "$HOME/.claude/commands"
