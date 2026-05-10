#!/bin/sh
mkdir -p "$HOME/.claude"
ln -svf "$DOTFILES_HOME/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -svf "$DOTFILES_HOME/claude/settings.json" "$HOME/.claude/settings.json"
rm -rf "$HOME/.claude/commands"
ln -svf "$DOTFILES_HOME/claude/commands" "$HOME/.claude/commands"
rm -rf "$HOME/.claude/bin"
ln -svf "$DOTFILES_HOME/claude/bin" "$HOME/.claude/bin"
