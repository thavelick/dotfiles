#!/bin/sh
# Print tracked files whose first line is a bash or sh shebang.
# Used by `make lint` and `make lint-fix` to discover what to check.
set -eu

cd "$(git rev-parse --show-toplevel)"

git ls-files | while IFS= read -r f; do
	[ -f "$f" ] || continue
	IFS= read -r first < "$f" 2>/dev/null || continue
	case "$first" in
		'#!'*bash*) ;;
		'#!'*/sh|'#!'*/sh' '*) ;;
		'#!'*' env sh'|'#!'*' env sh '*) ;;
		*) continue ;;
	esac
	printf '%s\n' "$f"
done
