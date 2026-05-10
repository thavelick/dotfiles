#!/bin/sh
mkdir -p "$HOME/.claude"
rm -rf "$HOME/.claude/skills"
ln -svf "$DOTFILES_HOME/agent-skills" "$HOME/.claude/skills"
