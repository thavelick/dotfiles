#!/bin/bash
set -e

[ -x /usr/local/zig/zig ] && exit 0

architecture=$(uname -m)
version="0.9.1"
archive="zig-linux-${architecture}-${version}"
url="https://ziglang.org/download/${version}/${archive}.tar.xz"

curl -L "$url" -o "/tmp/${archive}.tar.xz"

mkdir -p /tmp/zig
tar -xf /tmp/"${archive}.tar.xz" -C /tmp/zig

sudo mkdir -p /usr/local/zig
# shellcheck disable=SC2086
sudo cp -R /tmp/zig/${archive}/* /usr/local/zig/.
sudo chown -R root:root /usr/local/zig
rm -rf /tmp/zig "/tmp/${archive}.tar.xz"
