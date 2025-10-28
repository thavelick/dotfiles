#!/usr/bin/env bash
# Check that package files are alphabetically sorted

set -euo pipefail

# Color codes
red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

exit_code=0

for file in arch/packages-*; do
    if [ -f "$file" ]; then
        echo "  Checking $file..."

        # Capture sort output and exit code
        if output=$(LC_ALL=C sort -c "$file" 2>&1); then
            echo "  ${green}✓${reset} $file is properly sorted"
        else
            echo "$output"
            echo "  ${red}✗${reset} ERROR: $file is not alphabetically sorted"
            echo "  Run 'LC_ALL=C sort $file -o $file' to fix"
            exit_code=1
        fi
    fi
done

exit $exit_code
