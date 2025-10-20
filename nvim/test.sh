#!/bin/bash
set -e

echo "Testing neovim installation..."

# Test 1: nvim is installed
echo -n "Testing nvim is installed... "
if command -v nvim &> /dev/null; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 2: nvim version is correct
echo -n "Testing nvim version (should be 0.11.4)... "
NVIM_VERSION=$(nvim --version | head -1 | grep -oP 'NVIM v\K[0-9.]+')
if [[ "$NVIM_VERSION" == "0.11.4" ]]; then
    echo "✓"
else
    echo "✗"
    echo "Expected: 0.11.4, Got: $NVIM_VERSION"
    exit 1
fi

# Test 3: nvim config loads without errors
echo -n "Testing nvim config loads... "
if nvim --headless -c 'quit' 2>&1 | grep -q "Error"; then
    echo "✗"
    echo "nvim config has errors:"
    nvim --headless -c 'quit' 2>&1 | head -20
    exit 1
else
    echo "✓"
fi

# Test 4: vim symlinks exist
echo -n "Testing vim symlinks... "
if [[ -L ~/.config/nvim/init.lua ]] && [[ -L ~/.vim ]] && [[ -L ~/.vimrc ]]; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 5: packer plugins are installed
echo -n "Testing packer plugins installed... "
PLUGIN_COUNT=$(find ~/.local/share/nvim/site/pack/packer/start -maxdepth 1 -type d | wc -l)
# Should have at least packer.nvim + some plugins (let's say at least 5 dirs)
if [[ $PLUGIN_COUNT -gt 5 ]]; then
    echo "✓ ($PLUGIN_COUNT plugins)"
else
    echo "✗ (only $PLUGIN_COUNT plugins found)"
    exit 1
fi

echo "All nvim tests passed! ✓"
