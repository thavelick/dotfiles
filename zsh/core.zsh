# PATH
export PATH=$PATH:$HOME/.local/bin:$HOME/.claude/local:$HOME/.lmstudio/bin:$HOME/dotfiles-bin

# History settings
export HISTSIZE=100000
export SAVEHIST=100000

mkdir -p ~/.cache/zsh
export HISTFILE=~/.cache/zsh/history
export HISTORY_IGNORE="(ls|cd|pwd|exit|cd)*"

setopt AUTOCD                # Change directories without 'cd'
setopt EXTENDED_HISTORY      # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY    # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY         # Share history between all sessions.
setopt HIST_IGNORE_DUPS      # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS  # Delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_SPACE     # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS     # Do not write a duplicate event to the history file.
setopt HIST_VERIFY           # Do not execute immediately upon history expansion.
setopt APPEND_HISTORY        # append to history file (Default)
setopt HIST_NO_STORE         # Don't store history commands
setopt HIST_REDUCE_BLANKS    # Remove superfluous blanks from each command line being added to the history.

# Basic environment variables
export DOTFILES_HOME=$HOME/Projects/dotfiles
export GPG_TTY=$TTY
export PYTHONPATH=.

# Platform-specific environment setup
if command_exists nvim; then
    export EDITOR=nvim
elif command_exists vim; then
    export EDITOR=vim
else
    export EDITOR=vi
fi

# Man pager - prefer bat, fallback to nvim
if command_exists bat; then
    export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"
elif command_exists nvim; then
    export MANPAGER='nvim +Man!'
fi

# Browser detection - use first available
if command_exists firefox; then
    export BROWSER=firefox
elif command_exists chrome; then
    export BROWSER=chrome
elif command_exists chromium; then
    export BROWSER=chromium
elif [[ "$(get_os_type)" == "macos" ]]; then
    export BROWSER=open
elif command_exists xdg-open; then
    export BROWSER=xdg-open
fi

# Wayland-specific
if is_wayland; then
    export MOZ_ENABLE_WAYLAND="1"
fi

# macOS keychain auto-unlock for SSH sessions
[[ "$(get_os_type)" == "macos" && -n "$SSH_CONNECTION" ]] && ! security show-keychain-info ~/Library/Keychains/login.keychain-db 2>/dev/null && security unlock-keychain ~/Library/Keychains/login.keychain-db

# Keyboard layout (only matters on systems that use it)
export XKB_DEFAULT_LAYOUT="us(colemak)"
export XKB_DEFAULT_OPTIONS=ctrl:nocaps

# Help system
export HELPDIR=/usr/share/zsh/"${ZSH_VERSION}"/help

# Enable interactive comments
setopt interactive_comments

# If windows defaults us to its home directory, switch to the unix one
[[ $(pwd) = "/mnt/c/Users/trist" ]] && cd $HOME || true

# Store secrets outside of source control
source_if_exists $HOME/secrets.zsh

# Work environment
source_if_exists $HOME/work.zsh && source_if_exists $DOTFILES_HOME/work/github.sh

# Project-specific configs
source_if_exists $DOTFILES_HOME/gemini.sh

# zsh-autosuggestions color (works in both light and dark mode)
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#586e75"

# Theme switching signal handler for darkman integration
handle_theme_signal() {
    # Force prompt refresh to pick up new theme
    zle && zle reset-prompt
}

# Set up USR1 signal handler for theme switching
trap handle_theme_signal USR1

# Save current working directory for river/foot spawning
update_current_pwd() {
    mkdir -p ~/.cache/zsh
    pwd > ~/.cache/zsh/current_pwd
}

# Update pwd when directory changes or command completes
chpwd_functions+=(update_current_pwd)
precmd_functions+=(update_current_pwd)
