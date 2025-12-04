#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"

echo "Installing custom PKGBUILDs..."

mkdir -p "$BUILD_DIR"

for pkgdir in "$SCRIPT_DIR"/*/; do
  if [[ -f "$pkgdir/PKGBUILD" ]]; then
    pkgname=$(basename "$pkgdir")
    echo "Building and installing $pkgname..."

    pkg_build_dir="$BUILD_DIR/$pkgname"
    mkdir -p "$pkg_build_dir"
    cp "$pkgdir/PKGBUILD" "$pkg_build_dir/"

    (
      cd "$pkg_build_dir"
      makepkg -si --noconfirm
    )

    echo "✓ $pkgname installed"
  fi
done

echo "All custom packages installed!"
