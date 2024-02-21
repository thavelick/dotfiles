#!/bin/bash
set -e
[ -x "$(command -v river)" ] && exit 0

version="0.1.3"
archive="river-${version}"
url="https://github.com/riverwm/river/releases/download/v${version}/${archive}.tar.gz"

curl -L "$url" -o "/tmp/${archive}.tar.gz"

mkdir -p /tmp/river
tar -xf "/tmp/${archive}.tar.gz" -C /tmp/river

zig build -Doptimize=ReleaseSafe --prefix ~/.local install
