#!/bin/bash
set -e
# Use environment variable if set, otherwise use current directory
DOTFILES_HOME=${DOTFILES_HOME:-$(pwd)}
export DOTFILES_HOME

# Parse command line arguments
NO_GUI=false
CORE_ONLY=false
SKIP_PACKAGES=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --no-gui|--cli-only)
      NO_GUI=true
      shift
      ;;
    --core)
      CORE_ONLY=true
      shift
      ;;
    --skip-packages)
      SKIP_PACKAGES=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--no-gui|--cli-only] [--core] [--skip-packages]"
      exit 1
      ;;
  esac
done
if [ "$(uname)" = 'Darwin' ]; then
  mac/install.sh
elif grep -qF Debian /etc/issue; then
  debian/install.sh
else # Assume Arch or derivatives
  # Install packages unless --skip-packages is set
  if [ "$SKIP_PACKAGES" = false ]; then
    PACKAGE_FLAGS=()
    [ "$CORE_ONLY" = true ] && PACKAGE_FLAGS+=("--core")
    [ "$NO_GUI" = true ] && PACKAGE_FLAGS+=("--no-gui")
    "$DOTFILES_HOME/arch/install-packages.sh" "${PACKAGE_FLAGS[@]}"
  fi

  # Run setup scripts based on GUI flag
  if [ "$NO_GUI" = false ] && [ "$CORE_ONLY" = false ]; then
    "$DOTFILES_HOME"/waybar/setup.sh
    "$DOTFILES_HOME"/river/setup.sh
    "$DOTFILES_HOME"/foot/setup.sh
    "$DOTFILES_HOME"/font/setup.sh
    "$DOTFILES_HOME"/systemd/setup.sh
  fi

  "$DOTFILES_HOME"/dotfiles-bin/setup.sh
  "$DOTFILES_HOME"/git/setup.sh
  "$DOTFILES_HOME"/nag_runner/setup.sh
  "$DOTFILES_HOME"/amfora/setup.sh
  "$DOTFILES_HOME"/tidy/setup.sh
  "$DOTFILES_HOME"/tmux/setup.sh
fi

"$DOTFILES_HOME"/sfx/setup.sh
"$DOTFILES_HOME"/vim/setup.sh
"$DOTFILES_HOME"/zsh/setup.sh
