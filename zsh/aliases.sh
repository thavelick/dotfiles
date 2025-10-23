#!/bin/bash
# Ensure DOTFILES_HOME is set
[[ -z "$DOTFILES_HOME" ]] && echo "Warning: DOTFILES_HOME not set" >&2

# Basic aliases that should work everywhere
alias ls='ls --color=auto'

# Conditional aliases based on available commands
command_exists nvim && alias vim='nvim'
command_exists pmset && alias off='pmset displaysleepnow'

# Diff alias - use GNU diff color if available
diff --version 2>/dev/null | grep -q GNU && alias diff='diff --color'

# Date alias for macOS compatibility
[[ ! -f /opt/homebrew/bin/gdate ]] && alias gdate='date'

# Text viewing
alias vat="vim -R -c 'set nomodifiable' -c 'nmap q :q!<CR>' -c 'set norelativenumber'"

# Python-based aliases
if command_exists python3; then
    alias count_tokens='python3 -c '\''import tiktoken, sys; encoding = tiktoken.encoding_for_model("gpt-3.5-turbo"); token_count = len(encoding.encode(sys.stdin.read())); print(token_count)'\'''
fi

# Project-specific aliases
[[ -f "$HOME/Projects/ai-asker/ask.py" ]] && alias ask='$HOME/Projects/ai-asker/ask.py'
[[ -f "$HOME/Projects/ai-asker/ask.py" ]] && alias ask4='$HOME/Projects/ai-asker/ask.py --model gpt-4'
[[ -f "$HOME/Projects/dotfiles/git/auto-commit.sh" ]] && alias autocommit='$HOME/Projects/dotfiles/git/auto-commit.sh'
[[ -f "$DOTFILES_HOME/ghreadme.sh" ]] && alias ghreadme='$DOTFILES_HOME/ghreadme.sh'
command_exists python3 && [[ -f "$HOME/Projects/nag-runner/nag_runner.py" ]] && alias nag='python3 $HOME/Projects/nag-runner/nag_runner.py'

if [[ -f "$HOME/Projects/stock-tsv/venv/bin/python3" ]] && [[ -f "$HOME/Projects/stock-tsv/stock_tsv.py" ]] && command_exists wl-copy; then
    alias clipstocks='SYMBOLS=VFIAX,VTIVX,VTSAX $HOME/Projects/stock-tsv/venv/bin/python3 $HOME/Projects/stock-tsv/stock_tsv.py | wl-copy'
fi

# Media player aliases
command_exists mpv && alias mpv="mpv --no-terminal"
command_exists mpv && alias mpvi="mpv --no-terminal --loop-file"

# Busybox utilities
if command_exists busybox; then
    alias ed="busybox ed"
    alias nc="busybox nc"
    alias nslookup="busybox nslookup"
fi

# Email sync
if command_exists mbsync && command_exists notmuch; then
    alias mailsync="mbsync primary && notmuch new"
fi

# Backward compatibility aliases for renamed scripts
alias q='url-query'
alias qv='video-query'

# Enhanced SFTP with readline support
command_exists rlwrap && command_exists sftp && alias sftp='rlwrap -a -c sftp'

# LLM aliases
if command_exists llm; then
    alias llmt="llm --model thinking"
    alias llmg="llm --model grounded -o google_search 1"
    alias llmb="llm --model fast -s 'be relatively brief. Your answer should fit on a standard 80x25 terminal screen.'"
fi


alias namedcat='awk '\''FNR==1 {print "==> " FILENAME " <=="} {print}'\'
