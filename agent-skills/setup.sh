#!/bin/sh
TARGET="$HOME/.claude/skills"
SOURCE="$DOTFILES_HOME/agent-skills"

mkdir -p "$HOME/.claude"

if [ -L "$TARGET" ] && [ "$(readlink "$TARGET")" = "$SOURCE" ]; then
  echo "$TARGET already linked to $SOURCE"
  exit 0
fi

if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
  printf '\033[1;31m⚠️  WARNING: %s already exists and is not the expected symlink.\033[0m\n' "$TARGET" >&2
  printf '\033[1;31m⚠️  Refusing to overwrite. Move or remove it manually, then re-run.\033[0m\n' >&2
  exit 1
fi

ln -svf "$SOURCE" "$TARGET"
