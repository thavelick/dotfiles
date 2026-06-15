#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"

usage() {
  cat <<'EOF'
Usage: install.sh [options] [package]

Build and install custom PKGBUILDs from this directory. With no package,
processes every PKGBUILD here. Only (re)builds when the installed version
differs from the PKGBUILD's version.

Options:
  -f, --force    Rebuild even if the installed version already matches
  -h, --help     Show this help

Examples:
  install.sh                        # build/update all custom packages
  install.sh slack-desktop-wayland  # build/update just one
  install.sh --force zmx            # force rebuild one
EOF
}

force="${FORCE:-}"
only_pkg=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--force) force=1 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    *)
      if [[ -n "$only_pkg" ]]; then
        echo "Unexpected extra argument: $1" >&2; exit 1
      fi
      only_pkg="$1"
      ;;
  esac
  shift
done

# Print "pkgname|pkgver-pkgrel" for a PKGBUILD without building it. Sourced in a
# subshell so the dynamic pkgver (e.g. slack scraping its latest release) runs
# but nothing leaks into our scope.
pkg_target() {
  (
    cd "$1" || exit 1
    # shellcheck disable=SC1091  # PKGBUILD is data, not a script to follow
    . ./PKGBUILD >/dev/null 2>&1
    # shellcheck disable=SC2154  # pkgname/pkgver/pkgrel are set by the sourced PKGBUILD
    printf '%s|%s-%s' "$pkgname" "$pkgver" "${pkgrel:-1}"
  )
}

build_pkg() {
  local pkgdir="$1"
  local meta pkgname target installed
  meta=$(pkg_target "$pkgdir")
  pkgname=${meta%%|*}
  target=${meta#*|}
  installed=$(pacman -Q "$pkgname" 2>/dev/null | awk '{print $2}')

  if [[ -z "$force" && "$installed" == "$target" ]]; then
    echo "✓ $pkgname already up to date ($installed)"
    return
  fi

  echo "Building and installing $pkgname ($target)..."
  local pkg_build_dir="$BUILD_DIR/$pkgname"
  mkdir -p "$pkg_build_dir"
  # Copy PKGBUILD plus any local source files (patches, .install, etc.)
  cp "$pkgdir"/* "$pkg_build_dir/"

  (
    cd "$pkg_build_dir"
    makepkg -si --noconfirm
  )

  echo "✓ $pkgname installed"
}

mkdir -p "$BUILD_DIR"

if [[ -n "$only_pkg" ]]; then
  pkgdir="$SCRIPT_DIR/$only_pkg"
  if [[ ! -f "$pkgdir/PKGBUILD" ]]; then
    echo "No PKGBUILD found for '$only_pkg' in $SCRIPT_DIR" >&2
    exit 1
  fi
  echo "Installing custom PKGBUILD: $only_pkg..."
  build_pkg "$pkgdir"
  echo "Done!"
else
  echo "Installing custom PKGBUILDs..."
  for pkgdir in "$SCRIPT_DIR"/*/; do
    [[ -f "$pkgdir/PKGBUILD" ]] || continue
    build_pkg "$pkgdir"
  done
  echo "All custom packages installed!"
fi
