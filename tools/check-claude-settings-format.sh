#!/bin/sh
# Fails if claude/settings.json is not in canonical sorted/indented form.
# `make format` will fix it.

set -eu

file="claude/settings.json"
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

jq -S --indent 2 . "$file" > "$tmp"

if ! diff -q "$file" "$tmp" >/dev/null 2>&1; then
  printf '\033[1;31m%s is not in canonical format. Run: make format\033[0m\n' "$file" >&2
  exit 1
fi
