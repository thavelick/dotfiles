#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing custom PKGBUILDs..."

for pkgdir in "$SCRIPT_DIR"/*/; do
  if [[ -f "$pkgdir/PKGBUILD" ]]; then
    pkgname=$(basename "$pkgdir")
    echo "Building and installing $pkgname..."

    (
      cd "$pkgdir"
      makepkg -si --noconfirm
    )

    echo "✓ $pkgname installed"
  fi
done

echo "All custom packages installed!"
