#!/bin/bash
# Helper functions for portable shell configuration

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Source a file if it exists
source_if_exists() {
    # shellcheck disable=SC1090  # Dynamic source paths can't be statically analyzed
    [[ -f "$1" ]] && . "$1"
}

# Get clipboard command based on what's available
get_clipboard_copy_cmd() {
    if command_exists wl-copy; then
        echo "wl-copy"
    elif command_exists xclip; then
        echo "xclip -selection clipboard"
    elif command_exists pbcopy; then
        echo "pbcopy"
    else
        echo "cat > /tmp/clipboard.txt"
    fi
}

get_clipboard_paste_cmd() {
    if command_exists wl-paste; then
        echo "wl-paste"
    elif command_exists xclip; then
        echo "xclip -selection clipboard -o"
    elif command_exists pbpaste; then
        echo "pbpaste"
    else
        echo "cat /tmp/clipboard.txt 2>/dev/null || echo ''"
    fi
}

# Detect OS type
get_os_type() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *)       echo "unknown" ;;
    esac
}

# Check if running under Wayland
is_wayland() {
    [[ -n "$WAYLAND_DISPLAY" ]]
}

# Check if currently in an SSH session
is_ssh() {
    [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]
}

