#!/bin/bash
set -e

# Script to classify dotfiles in ~ and ~/.config
# Determines if files are already symlinked, ignored, or contain secrets

# Get dotfiles directory
DOTFILES_HOME=${DOTFILES_HOME:-$(dirname "$(dirname "$(realpath "$0")")}")}

# Test mode - only check first few files
TEST_MODE=${1:-false}
MAX_FILES=5

# List of paths to ignore (cache dirs, logs, etc.)
IGNORED_PATHS=(
    ".cache"
    ".local/share/Trash"
    ".local/share/recently-used.xbel"
    ".mozilla/firefox/*/crashes"
    ".mozilla/firefox/*/datareporting"
    ".mozilla/firefox/*/saved-telemetry-pings"
    ".mozilla/firefox/*/sessionstore-backups"
    ".thumbnails"
    ".xsession-errors"
    ".bash_history"
    ".zsh_history"
    ".lesshst"
    ".python_history"
    ".viminfo"
    ".sqlite_history"
    ".node_repl_history"
    ".config/Code/logs"
    ".config/Code/User/workspaceStorage"
    ".config/Code/CachedExtensions"
    ".config/chromium"
    ".config/google-chrome"
    ".config/pulse"
    ".config/dconf"
    ".gtkrc-2.0"
    ".ICEauthority"
    ".Xauthority"
    ".var"
    ".cargo"
    ".rustup"
    ".npm"
    ".yarn"
    ".gem"
    ".rvm"
    ".nvm"
    ".docker"
    ".kube"
    ".minikube"
    ".gradle"
    ".m2"
    ".ivy2"
    ".sbt"
    ".android"
    ".vscode"
    ".cursor"
    ".pub-cache"
    ".dart_tool"
    ".cookiecutters"
    ".steam"
    ".wine"
    ".PlayOnLinux"
    ".local/lib"
    ".local/bin"
    ".local/include"
    ".zsh_history"
    ".duckdb_history"
    ".ash_history"
    ".sc_history"
    ".units_history"
    ".histfile"
    ".pulse-cookie"
    ".rnd"
    ".emulator_console_auth_token"
    ".oh-my-zsh"
    ".zotero"
    ".crawl"
    ".emulationstation"
    ".ape-1.10"
    ".flutter"
    ".dart"
    ".haxelib"
    ".lime"
    ".texlive"
    ".cmake"
    ".ansible"
    ".ipython"
    ".idlerc"
    ".pki"
    ".elinks"
    ".links"
    ".newsboat"
    ".upodder"
    ".zcompdump"
    ".zcompdump-*"
    ".pre-oh-my-zsh"
    ".zshrc.pre-oh-my-zsh*"
    ".shell.pre-oh-my-zsh"
    ".fehbg"
    ".b2_account_info"
    ".claude"
    ".claude.json"
    ".aider"
    ".aider.*"
    ".notmuch-config"
    ".mbsync"
    ".mbsyncrc"
    ".msmtp"
    ".msmtprc"
    ".msmtpqueue"
)

# Arrays to store results
CLEAN_FILES=()
SECRET_FILES=()
ALREADY_SYMLINKED=()
CHECKED_PATHS=()
LARGE_DIRS_SKIPPED=()

# Function to check if path is ignored
is_ignored() {
    local path="$1"
    for ignored in "${IGNORED_PATHS[@]}"; do
        if [[ "$path" == *"$ignored"* ]]; then
            return 0
        fi
    done
    return 1
}

# Function to check if path is already checked (to avoid checking subdirs)
is_already_checked() {
    local path="$1"
    for checked in "${CHECKED_PATHS[@]}"; do
        if [[ "$path" == "$checked"/* ]]; then
            return 0
        fi
    done
    return 1
}

# Function to check if file/dir is symlinked to dotfiles repo
is_symlinked_to_repo() {
    local path="$1"
    if [[ -L "$path" ]]; then
        local target
        target=$(readlink -f "$path")
        if [[ "$target" == *"/dotfiles/"* ]]; then
            return 0
        fi
    fi
    return 1
}

# Function to check for secrets using gitleaks directly
has_secrets() {
    local path="$1"
    # Skip directories that are too large or problematic
    if [[ -d "$path" ]]; then
        local size
        size=$(du -sh "$path" 2>/dev/null | cut -f1 | sed 's/[^0-9.]//g')
        if [[ "${size%.*}" -gt 100 ]]; then
            LARGE_DIRS_SKIPPED+=("$path")
            return 1
        fi
    fi
    
    local output
    output=$(timeout 10s gitleaks dir --redact "$path" 2>&1) || true
    
    if echo "$output" | grep -q "leaks found"; then
        return 0
    else
        return 1
    fi
}

echo "Classifying dotfiles in ~ and ~/.config..."

# Find all dotfiles in home directory (hidden files/dirs)
file_count=0

# Use mapfile to read find results into array
mapfile -t dotfiles < <(find "$HOME" -maxdepth 1 -name ".*" -not -name "." -not -name "..")

for file in "${dotfiles[@]}"; do
    # Stop if in test mode and reached max files
    if [[ "$TEST_MODE" == "test" ]] && [[ $file_count -ge $MAX_FILES ]]; then
        break
    fi
    
    # Skip if already checked under a parent path
    if is_already_checked "$file"; then
        continue
    fi
    
    # Skip if ignored
    if is_ignored "$file"; then
        continue
    fi
    
    # Check if symlinked to repo
    if is_symlinked_to_repo "$file"; then
        ALREADY_SYMLINKED+=("$file")
        CHECKED_PATHS+=("$file")
        continue
    fi
    
    # Check for secrets
    has_secrets "$file" && secrets_found=true || secrets_found=false
    if [[ "$secrets_found" == "true" ]]; then
        SECRET_FILES+=("$file")
    else
        CLEAN_FILES+=("$file")
    fi
    
    CHECKED_PATHS+=("$file")
    file_count=$((file_count + 1))
done

# Silently continue to .config

# Find all top-level files and directories in ~/.config
if [[ -d "$HOME/.config" ]]; then
    mapfile -t config_dirs < <(find "$HOME/.config" -maxdepth 1 -not -name ".config")
    
    for file in "${config_dirs[@]}"; do
        # Skip if already checked under a parent path
        if is_already_checked "$file"; then
            continue
        fi
        
        # Skip if ignored
        if is_ignored "$file"; then
            continue
        fi
        
        # Check if symlinked to repo
        if is_symlinked_to_repo "$file"; then
            ALREADY_SYMLINKED+=("$file")
            CHECKED_PATHS+=("$file")
            continue
        fi
        
        # Check for secrets
        has_secrets "$file" && secrets_found=true || secrets_found=false
        if [[ "$secrets_found" == "true" ]]; then
            SECRET_FILES+=("$file")
        else
            CLEAN_FILES+=("$file")
        fi
        
        CHECKED_PATHS+=("$file")
        
    done
fi

echo
echo "RESULTS:"
echo "========"

echo
echo "Files/dirs already symlinked to dotfiles repo (${#ALREADY_SYMLINKED[@]}):"
printf '%s\n' "${ALREADY_SYMLINKED[@]}"

echo
echo "Clean files (no secrets detected) (${#CLEAN_FILES[@]}):"
printf '%s\n' "${CLEAN_FILES[@]}"

echo
echo "Files with potential secrets (${#SECRET_FILES[@]}):"
printf '%s\n' "${SECRET_FILES[@]}"

echo
echo "Large directories skipped (${#LARGE_DIRS_SKIPPED[@]}):"
printf '%s\n' "${LARGE_DIRS_SKIPPED[@]}"