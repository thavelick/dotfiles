#!/bin/bash
set -e

sudo apt update
sudo apt upgrade
missing_packages=$(comm -13 <(dpkg-query -f '${Package}\n' -W | sort) <(sort debian/packages))

if [ -n "$missing_packages" ]; then
  # shellcheck disable=SC2086
  sudo apt install $missing_packages
fi

zig/install.sh
river/build.sh
river/setup.sh
amfora/setup.sh
foot/setup.sh
git/setup.sh
nag_runner/setup.sh
qutebrowser/setup.sh
waybar/setup.sh
