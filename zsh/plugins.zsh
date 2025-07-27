# Enable completions
autoload -U compinit && compinit

# Enable run-help for context-sensitive help
autoload run-help

# Zsh syntax highlighting - prefer pacman install, fallback to manual
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    ZSH_HIGHLIGHT_STYLES[comment]='fg=blue'
elif [[ -f $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    ZSH_HIGHLIGHT_STYLES[comment]='fg=blue'
else
    # Auto-install if git is available and directory doesn't exist
    if command_exists git && [[ ! -d $HOME/.zsh/zsh-syntax-highlighting ]]; then
        mkdir -p $HOME/.zsh
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.zsh/zsh-syntax-highlighting
        source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        ZSH_HIGHLIGHT_STYLES[comment]='fg=blue'
    fi
fi

# Zsh autosuggestions - prefer pacman install, fallback to manual
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [[ -f $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
else
    # Auto-install if git is available and directory doesn't exist
    if command_exists git && [[ ! -d $HOME/.zsh/zsh-autosuggestions ]]; then
        mkdir -p $HOME/.zsh
        git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.zsh/zsh-autosuggestions
        source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
    fi
fi

# FZF integration
if command_exists fzf; then
    # Source fzf key bindings and completion
    if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
        source /usr/share/fzf/key-bindings.zsh
    elif [[ -f /usr/local/opt/fzf/shell/key-bindings.zsh ]]; then
        source /usr/local/opt/fzf/shell/key-bindings.zsh
    elif [[ -f $HOME/.fzf/shell/key-bindings.zsh ]]; then
        source $HOME/.fzf/shell/key-bindings.zsh
    else
        # Try to source using fzf --zsh if available (newer versions)
        eval "$(fzf --zsh 2>/dev/null || true)"
    fi
fi

# Nag runner - only run if it exists
if [[ -f $HOME/Projects/nag-runner/nag_runner.py ]] && command_exists python3; then
    $HOME/Projects/nag-runner/nag_runner.py
fi