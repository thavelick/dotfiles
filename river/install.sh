#!/bin/bash
set -e
[ -x "$(command -v river)" ] && exit 0
rm -rf /tmp/river
ls /tmp
echo "about to clone river"
git clone https://github.com/riverwm/river /tmp/river
echo "about to install river"
cd /tmp/river && git submodule update --init && /usr/local/zig/zig build -Doptimize=ReleaseSafe --prefix ~/.local install
echo "done installing river"
