#!/bin/sh
# Links only the machine-independent agent files (skills, agent docs, global
# CLAUDE.md), so a headless VM can share them without the Mac settings.json.
: "${DOTFILES_HOME:?set DOTFILES_HOME to the dotfiles checkout}"
mkdir -p "$HOME/.claude"
ln -svf "$DOTFILES_HOME/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
rm -rf "$HOME/.claude/agent-docs"
ln -svf "$DOTFILES_HOME/agent-docs" "$HOME/.claude/agent-docs"

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
