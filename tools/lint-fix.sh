#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "Applying shellcheck auto-fixes.."
./tools/list-shell-files.sh | while IFS= read -r f; do
    diff=$(shellcheck -f diff "$f" 2>/dev/null || true)
    if [ -n "$diff" ]; then
        echo "Patching $f"
        printf '%s\n' "$diff" | patch -p0 "$f"
    fi
done

echo
echo "Re-running shellcheck.."
./tools/list-shell-files.sh | xargs shellcheck
