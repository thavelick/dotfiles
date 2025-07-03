# Plan: Make zshrc Portable with Silent Graceful Degradation

## Overview
Make the zshrc configuration work across different Linux distributions and macOS by detecting available commands and gracefully degrading when dependencies are missing. No automatic installations - only use what's already available on the system.

## Implementation Steps

### 1. Add command detection helper functions
- Create a `command_exists()` function to check if commands are available
- Create a `source_if_exists()` function to source files only if they exist

### 2. Wrap external dependencies in existence checks
- **Zsh plugins**: Only source if `~/.zsh/zsh-syntax-highlighting/` and `~/.zsh/zsh-autosuggestions/` exist
- **Editor**: Only alias `vim=nvim` if `nvim` exists
- **Clipboard tools**: Detect which clipboard manager is available (wl-copy, xclip, pbcopy)
- **Other tools**: Check before creating aliases/functions that depend on:
  - `fzf`, `sdcv`, `qrencode`, `imv`, `elinks`, `yt-dlp`, `pandoc`
  - `mbsync`, `notmuch`, `llm`, `busybox`
  - Python scripts in specific paths

### 3. Create platform-aware configurations
- **Clipboard functions**: Create unified clipboard functions that use:
  - `wl-copy`/`wl-paste` on Wayland
  - `xclip` or `xsel` on X11  
  - `pbcopy`/`pbpaste` on macOS
- **Browser**: Set BROWSER to first available: `firefox`, `chrome`, `open` (macOS), `xdg-open`
- **Man pager**: Only set if `nvim +Man!` works

### 4. Make conditional features actually conditional
- River auto-start: Only if `river` command exists and on tty1
- Git prompt features: Already checks if in git repo, but also check if `git` exists
- Work environment: Already conditional on `work.zsh` existing
- Distro icon: Extend to show macOS icon if on Darwin

### 5. Refactor into modular structure
Instead of one large zshrc, split into:
- `zsh/zshrc` - Main file that sources modules
- `zsh/core.zsh` - Universal settings (history, basic exports, PATH)
- `zsh/aliases.zsh` - All aliases with existence checks
- `zsh/functions.zsh` - All functions with dependency checks
- `zsh/prompt.zsh` - Prompt configuration
- `zsh/plugins.zsh` - Plugin loading

This makes the config cleaner and easier to maintain while ensuring everything degrades gracefully on systems missing dependencies.

## Key Principles
- Never install anything automatically
- Silently skip unavailable features
- Maintain full functionality on the primary Arch Linux system
- Provide reasonable degradation on other systems
- Keep the configuration modular and maintainable