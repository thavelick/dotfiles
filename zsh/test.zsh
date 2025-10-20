#!/bin/zsh

# Test script for minimal zshrc functionality
set -e

echo "Testing minimal zshrc functionality..."

# Check what shell we're running
echo "Current shell: $0"
echo "Shell version: $ZSH_VERSION"

echo "DOTFILES_HOME is: $DOTFILES_HOME"

# Test 1: Basic aliases
echo -n "Testing ls alias... "
if alias ls | grep -q "ls --color=auto"; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 2: History directory creation
echo -n "Testing history directory... "
ls -la ~/.cache/ || echo "No .cache dir"
if [[ -d ~/.cache/zsh ]]; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 3: DOTFILES_HOME is set
echo -n "Testing DOTFILES_HOME... "
if [[ -n "$DOTFILES_HOME" ]]; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 4: namedcat alias
echo -n "Testing namedcat alias... "
if alias namedcat >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 5: History settings
echo -n "Testing history settings... "
if [[ "$HISTSIZE" == "100000" && "$SAVEHIST" == "100000" ]]; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 6: Basic prompt rendering
echo -n "Testing basic prompt rendering... "
cd ~
prompt_output=$(print -P '%~ $(distro_icon)')
if [[ "$prompt_output" =~ "~" ]] && [[ "$prompt_output" =~ "꩜" ]]; then
    echo "✓"
else
    echo "✗"
    echo "Expected: ~ with ꩜"
    echo "Got: $prompt_output"
    exit 1
fi

echo "All tests passed! ✓"

# Run nvim tests
echo ""
bash "$DOTFILES_HOME/nvim/test.sh"