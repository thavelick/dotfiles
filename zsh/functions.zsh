# LLM code function
if command_exists llm; then
    llmc() {
        local code=$(llm -s 'code in zsh for archlinux. Keep it as simple and brief as possible. Output only the code requested, no commentary. No shebang. Only one example.' --xl "$@" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        print -z "$code"
    }
fi

# Summary function with dependencies
if command_exists curl && command_exists llm && command_exists pandoc && command_exists firefox; then
    summary() {
        curl -s "https://r.jina.ai/$1" | llm "summarize this text" | pandoc -f markdown -t html > /tmp/summary.html && firefox /tmp/summary.html
    }
fi

# QR code paste function
qr-paste() {
    local paste_cmd=$(get_clipboard_paste_cmd)
    if command_exists qrencode && command_exists imv; then
        local temp_file=$(mktemp --suffix=.png)
        $paste_cmd | qrencode -o "$temp_file" -t PNG -d 300 && imv "$temp_file"
        rm -f "$temp_file"
    else
        echo "qr-paste requires qrencode and imv to be installed"
    fi
}

# Dictionary function
if command_exists sdcv && command_exists elinks && command_exists less; then
    def() {
        sdcv -n --utf8-output "$@" 2>&1 | sed 's/-->/<p>-->/g' | elinks -dump | less -EXFRfM
    }
fi

# Unicode clipboard function
if command_exists fzf; then
    uniclip() {
        local clipboard_cmd=$(get_clipboard_copy_cmd)
        cat $DOTFILES_HOME/zsh/latex_symbols.txt 2>/dev/null | fzf --query $1 | tr -s ' ' | cut -d ' ' -f2 | tr -d "\n" | $clipboard_cmd
    }
fi


# Question function for web content
if command_exists curl && command_exists llm; then
    q() {
        local url="$1"
        local question="$2"

        # Fetch the URL content through Jina
        local content=$(curl -s "https://r.jina.ai/$url")

        # Check if the content was retrieved successfully
        if [ -z "$content" ]; then
            echo "Failed to retrieve content from the URL."
            return 1
        fi

        system="
        You are a helpful assistant that can answer questions about the content.
        Reply concisely, in a few sentences.

        The content:
        ${content}
        "

        # Use llm with the fetched content as a system prompt
        llm prompt "$question" -s "$system"
    }
fi

# Video question function
if command_exists yt-dlp && command_exists curl && command_exists llm; then
    qv() {
        local url="$1"
        local question="$2"

        # Fetch the URL content through Jina
        local subtitle_url=$(yt-dlp -q --skip-download --convert-subs srt --write-sub --sub-langs "en" --write-auto-sub --print "requested_subtitles.en.url" "$url")
        local content=$(curl -s "$subtitle_url" | sed '/^$/d' | grep -v '^[0-9]*$' | grep -v '\-->' | sed 's/<[^>]*>//g' | tr '\n' ' ')

        # Check if the content was retrieved successfully
        if [ -z "$content" ]; then
            echo "Failed to retrieve content from the URL."
            return 1
        fi
    }
fi

function -() {
    cd -
}

# Run-help configuration
unalias run-help 2>/dev/null || true
autoload run-help

# Python help function
python_help() {
    [[ $# -eq 0 ]] && { man python; return; }
    
    local target="$1"
    local version="$2"
    local script_path="$DOTFILES_HOME/zsh/python_help.py"
    
    # Parse version spec (e.g., flask==2.0.0 or flask>=1.0)
    local package_spec="$target"
    if [[ -n "$version" ]]; then
        package_spec="${target}${version}"
    fi
    
    # Handle dot notation like flask.Request or unittest.mock
    if [[ "$target" == *.* ]]; then
        local module="${target%%.*}"
        local module_spec="$module"
        if [[ -n "$version" ]]; then
            module_spec="${module}${version}"
        fi
        # Always try local Python first, then uv as fallback
        python "$script_path" "$target" 2>/dev/null || {
            command_exists uv && uv run --with "$module_spec" python "$script_path" "$target"
        }
    else
        # Use fzf to let user choose what to do
        if command_exists fzf; then
            local choice=$(echo -e "📋 Show summary\n📖 Module docs\n🔍 Browse items" | fzf --prompt="Choose help type for $target: " --height=5)
            
            case "$choice" in
                *"Show summary"*)
                    local summary_output
                    summary_output=$(python "$script_path" "$target" --summary 2>/dev/null) || {
                        if command_exists uv; then
                            echo "Trying with uv and version spec: $package_spec"
                            summary_output=$(uv run --with "$package_spec" python "$script_path" "$target" --summary 2>&1)
                            if [[ $? -ne 0 ]]; then
                                echo "Failed to install/run $package_spec:"
                                echo "$summary_output" | head -10
                                return 1
                            fi
                        fi
                    }
                    
                    if [[ -n "$summary_output" ]]; then
                        if command_exists glow; then
                            echo "$summary_output" | glow --pager
                        else
                            echo "$summary_output"
                        fi
                    fi
                    ;;
                *"Module docs"*)
                    # Try to get the correct import name first
                    local import_name
                    import_name=$(python "$script_path" "$target" --get-import-name 2>/dev/null) || import_name="$target"
                    python -m pydoc "$import_name" 2>/dev/null || { command_exists uv && uv run --with "$package_spec" python -m pydoc "$import_name"; }
                    ;;
                *"Browse items"*)
                    local selected
                    selected=$(python "$script_path" "$target" --fzf 2>/dev/null | fzf --prompt="Select item from $target: ") || {
                        command_exists uv && selected=$(uv run --with "$package_spec" python "$script_path" "$target" --fzf | fzf --prompt="Select item from $target: ")
                    }
                    
                    [[ -n "$selected" ]] && {
                        local item_name="${selected#*:}"
                        python_help "$target.$item_name"
                    }
                    ;;
            esac
        else
            # Fallback without fzf
            python "$script_path" "$target" --summary 2>/dev/null || {
                command_exists uv && uv run --with "$package_spec" python "$script_path" "$target" --summary
            }
        fi
    fi
}

# Enhanced help function that tries multiple sources
help() {
    local format_help() { command_exists bat && bat --plain --language=help || cat; }
    
    # Special handling for commands with broken run-help helpers
    case "$1" in
        git)
            [[ $# -eq 1 ]] && man git || { shift; git help "$@" 2>/dev/null || echo "No git help available for: $*"; }
            ;;
        ip)
            [[ $# -eq 1 ]] && man ip || {
                shift
                local subcmd="$1"
                man "ip-$subcmd" 2>/dev/null && return
                local match=$(man -k "ip-${subcmd}" 2>/dev/null | head -1 | cut -d' ' -f1)
                [[ -n "$match" ]] && man "$match" || man ip
            }
            ;;
        openssl)
            [[ $# -eq 1 ]] && man openssl || { shift; man "openssl-$1" 2>/dev/null || openssl "$1" -help 2>/dev/null || man openssl; }
            ;;
        uv)
            [[ $# -eq 1 ]] && uv help || { shift; uv help "$@"; }
            ;;
        docker)
            if [[ $# -eq 1 ]]; then
                man docker
            elif [[ $# -eq 2 && "$2" == "compose" ]]; then
                man docker-compose
            elif [[ "$2" == "compose" ]]; then
                shift 2
                docker compose "$@" --help | format_help
            else
                shift
                man "docker-$1" 2>/dev/null || docker help "$@"
            fi
            ;;
        rclone)
            [[ $# -eq 1 ]] && man rclone || { shift; rclone "$1" --help | format_help; }
            ;;
        gh)
            [[ $# -eq 1 ]] && gh help || { shift; gh help "$@"; }
            ;;
        python)
            [[ $# -eq 1 ]] && man python || { shift; python_help "$@"; }
            ;;
        *)
            local help_output=$(run-help "$1" 2>&1)
            
            # If run-help works, use it
            [[ "$help_output" != *"No manual entry"* ]] && { run-help "$1"; return $?; }
            
            command -v "$1" >/dev/null 2>&1 || { echo "$1: command not found"; return 1; }
            
            echo "No manual entry for $1, trying --help:"
            
            # Try --help with formatting
            local help_text=$("$1" --help 2>/dev/null)
            [[ -n "$help_text" ]] && { echo "$help_text" | format_help; return 0; }
            echo "Trying -h:"
            help_text=$("$1" -h 2>/dev/null)
            [[ -n "$help_text" ]] && { echo "$help_text" | format_help; return 0; }
            
            echo "No help available for $1"
            return 1
            ;;
    esac
}

# Create directory and cd into it
# From https://codeberg.org/EvanHahn/dotfiles/src/branch/main/home/zsh/.config/zsh/aliases.zsh
mkcd() {
    mkdir -p "$1"
    cd "$1"
}

# Create a temporary directory and cd into it
# From https://codeberg.org/EvanHahn/dotfiles/src/branch/main/home/zsh/.config/zsh/aliases.zsh
tempe() {
    cd "$(mktemp -d)"
    chmod -R 0700 .
    if [[ $# -eq 1 ]]; then
        mkdir -p "$1"
        cd "$1"
        chmod -R 0700 .
    fi
}

# Play sound based on last command's exit code
# From https://codeberg.org/EvanHahn/dotfiles/src/branch/main/home/zsh/.config/zsh/aliases.zsh
boop() {
    local last="$?"
    if [[ "$last" == '0' ]]; then
        sfx good
    else
        sfx bad
    fi
    $(exit "$last")
}
