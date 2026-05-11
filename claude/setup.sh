#!/bin/sh
mkdir -p "$HOME/.claude"
ln -svf "$DOTFILES_HOME/claude/settings.json" "$HOME/.claude/settings.json"
rm -rf "$HOME/.claude/commands"
ln -svf "$DOTFILES_HOME/claude/commands" "$HOME/.claude/commands"
rm -rf "$HOME/.claude/bin"
ln -svf "$DOTFILES_HOME/claude/bin" "$HOME/.claude/bin"

SKILLS_TARGET="$HOME/.claude/skills"
SKILLS_SOURCE="$DOTFILES_HOME/agent-skills"
if [ -L "$SKILLS_TARGET" ] && [ "$(readlink "$SKILLS_TARGET")" = "$SKILLS_SOURCE" ]; then
  echo "$SKILLS_TARGET already linked to $SKILLS_SOURCE"
elif [ -e "$SKILLS_TARGET" ] || [ -L "$SKILLS_TARGET" ]; then
  printf '\033[1;31m⚠️  WARNING: %s already exists and is not the expected symlink.\033[0m\n' "$SKILLS_TARGET" >&2
  printf '\033[1;31m⚠️  Refusing to overwrite. Move or remove it manually, then re-run.\033[0m\n' >&2
  exit 1
else
  ln -svf "$SKILLS_SOURCE" "$SKILLS_TARGET"
fi
