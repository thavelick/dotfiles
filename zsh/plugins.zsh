# Plugin loading with existence checks

# Zsh syntax highlighting
source_if_exists $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
if [[ -f $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    ZSH_HIGHLIGHT_STYLES[comment]='fg=blue'
fi

# Zsh autosuggestions
source_if_exists $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# FZF integration
if command_exists fzf; then
    # Source fzf key bindings and completion
    if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
        source /usr/share/fzf/key-bindings.zsh
    elif [[ -f /usr/local/opt/fzf/shell/key-bindings.zsh ]]; then
        source /usr/local/opt/fzf/shell/key-bindings.zsh
    elif [[ -f $HOME/.fzf/shell/key-bindings.zsh ]]; then
        source $HOME/.fzf/shell/key-bindings.zsh
    elif command_exists fzf; then
        # Try to source using fzf --zsh if available (newer versions)
        eval "$(fzf --zsh 2>/dev/null || true)"
    fi
fi

# Nag runner - only run if it exists
if [[ -f $HOME/Projects/nag-runner/nag_runner.py ]] && command_exists python3; then
    $HOME/Projects/nag-runner/nag_runner.py
fi