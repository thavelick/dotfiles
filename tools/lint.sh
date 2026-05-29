#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "Running shellcheck on shell files.."
if ! ./tools/list-shell-files.sh | xargs shellcheck; then
    echo
    echo "shellcheck found issues — run 'make lint-fix' to auto-apply fixes (review the diff before committing)"
    exit 1
fi

echo "Running ruff on Python files.."
(cd whisper && uv run ruff check .)

echo "Checking package files are alphabetically sorted.."
./tools/check-package-sort.sh

echo "Checking Claude theme is pinned.."
./tools/check-claude-theme.sh

echo "Checking Claude settings are formatted.."
./tools/check-claude-settings-format.sh
