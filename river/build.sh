#!/bin/bash
set -e

[ -x "$(command -v river)" ] && exit 0

version="0.1.3"
archive="river-${version}"
url="http://github.com/riverwm/river/releases/download/v${version}/${archive}.tar.gz"

curl -L "$url" -o "/tmp/${archive}.tar.gz"

mkdir -p /tmp/river
tar -xf "/tmp/${archive}.tar.gz" -C /tmp/river

cd /tmp/river/"${archive}" || exit 1
mkdir -p ~/.local
/usr/local/zig/zig build -Drelease-safe --prefix ~/.local install
rm -rf /tmp/river "/tmp/${archive}.tar.gz"
