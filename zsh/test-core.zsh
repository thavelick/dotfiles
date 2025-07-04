#!/bin/zsh

# Maximal test script for comprehensive zshrc functionality
set -e

echo "Testing core zshrc functionality after core install..."

# Check what shell we're running
echo "Current shell: $0"
echo "Shell version: $ZSH_VERSION"

echo "DOTFILES_HOME is: $DOTFILES_HOME"

# Test 1: Basic aliases from minimal test
echo -n "Testing ls alias... "
if alias ls | grep -q "ls --color=auto"; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 2: History directory creation
echo -n "Testing history directory... "
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
if [[ "$prompt_output" =~ "~" ]] && [[ "$prompt_output" =~ "⮝" ]]; then
    echo "✓"
else
    echo "✗"
    echo "Expected: ~ with ⮝ (container icon)"
    echo "Got: $prompt_output"
    exit 1
fi

# Test 7: FZF integration
echo -n "Testing FZF installation... "
if command -v fzf >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 8: Core package functionality
echo -n "Testing core package functionality... "
# Test that core packages are working properly
if command -v curl >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 9: Git configuration
echo -n "Testing git installation... "
if command -v git >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 10: tmux installation
echo -n "Testing tmux installation... "
if command -v tmux >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 11: neovim installation
echo -n "Testing neovim installation... "
if command -v nvim >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 12: zsh completions loaded
echo -n "Testing zsh completions... "
if [[ -n "$fpath" ]] && [[ "${fpath}" =~ "completions" ]]; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 13: Check if install.sh ran successfully (via marker files or configs)
echo -n "Testing git setup completion... "
if [[ -f ~/.gitconfig ]] || git config --get user.name >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 14: Check tmux config
echo -n "Testing tmux setup completion... "
if [[ -f ~/.tmux.conf ]] || [[ -L ~/.tmux.conf ]]; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 15: Check vim/neovim config
echo -n "Testing vim setup completion... "
if [[ -f ~/.vimrc ]] || [[ -L ~/.vimrc ]] || [[ -d ~/.config/nvim ]]; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 16: Advanced zsh features - autosuggestions if available
echo -n "Testing advanced zsh features... "
# Test if we can use advanced features without errors
if zsh -c 'setopt AUTO_CD; setopt HIST_VERIFY' 2>/dev/null; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

# Test 17: Package installation verification
echo -n "Testing CLI package installation... "
packages_to_check=("git" "tmux" "fzf" "nvim" "curl" "python3")
all_installed=true
for pkg in "${packages_to_check[@]}"; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
        all_installed=false
        break
    fi
done

if [[ "$all_installed" == true ]]; then
    echo "✓"
else
    echo "✗"
    exit 1
fi

echo "All core tests passed! ✓"
echo "Core installation and configuration verification complete."