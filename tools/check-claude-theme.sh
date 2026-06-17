#!/bin/sh
# Guard against /theme accidentally flipping the tracked theme value.
# Claude Code's /theme writes to ~/.claude/settings.json, which is a
# symlink to claude/settings.json in this repo — so changing the theme
# at runtime dirties the repo. We pin it to "auto" here so any drift
# fails lint and prompts a manual revert.

set -eu

settings="claude/settings.json"
expected="auto"

actual=$(jq -r '.theme // "missing"' "$settings")

if [ "$actual" != "$expected" ]; then
  printf '\033[1;31m%s has theme=%s, expected %s.\033[0m\n' "$settings" "$actual" "$expected" >&2
  printf 'Did /theme rewrite the file? Run: git checkout -- %s\n' "$settings" >&2
  exit 1
fi
