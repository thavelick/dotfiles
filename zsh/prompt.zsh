# Prompt configuration with Git support

# Load vcs_info for git integration
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '🚧'
zstyle ':vcs_info:*' stagedstr '💾'

# Command execution timing
preexec() {
    if command_exists gdate; then
        exec_start_time=$(gdate +%s%3N) # Record start time in milliseconds
    else
        exec_start_time=$(date +%s) # Fallback to seconds
    fi
}

set_prompt_time() {
    # Set prompt_time to show how long the last command took to run: 🐢 1m2s
    # It will only show if the command took longer than 5 seconds.

    prompt_time=''
    if [ "$exec_start_time" ]; then
        if command_exists gdate; then
            exec_end_time=$(gdate +%s%3N)
            exec_duration=$((exec_end_time - exec_start_time))
            exec_duration_seconds=$((exec_duration / 1000))
        else
            exec_end_time=$(date +%s)
            exec_duration_seconds=$((exec_end_time - exec_start_time))
        fi

        if (( exec_duration_seconds >= 5 )); then
            clock_icon="🐢"
            if (( exec_duration_seconds >= 60 )); then
                exec_duration_minutes=$((exec_duration_seconds / 60))
                exec_duration_seconds=$((exec_duration_seconds % 60))
                prompt_time="${clock_icon} ${exec_duration_minutes}m${exec_duration_seconds}s "
            else
                prompt_time="${clock_icon} ${exec_duration_seconds}s "
            fi
        fi
    fi
    exec_start_time=''
}

# Pre-command hook
precmd() {
    local last_exit=$?
    set_prompt_time

    if [[ $last_exit -ne 0 ]]; then
        prompt_error="%F{red}✗ ${last_exit}%f "
    else
        prompt_error=''
    fi

    current_directory=$(pwd)
    if [[ $current_directory != $HOME/Projects/* ]]; then
        # skip doing stuff with git prompts if we're outside of ~/Projects
        # to avoid running rogue payloads in untrusted folders
        vcs_info_msg_0_=''
        return
    fi

    # Only run git commands if git is available
    if command_exists git; then
        unpushed_commits=''
        untracked_files=''
        if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]; then
            # we're in a git project, show git info in the prompt
            unpushed_count=$(git rev-list --count @{u}.. 2>/dev/null || echo -1)
            if [[ $unpushed_count -eq -1 ]]; then
                # if we can't get the count, assume we're not tracking a remote
                unpushed_commits='📤'
            elif [[ $unpushed_count -gt 0 ]]; then
                unpushed_commits='🔥'
            fi
            if [[ -n $(git ls-files --others --exclude-standard) ]]; then
                untracked_files='🌱'
            fi
        fi
        zstyle ':vcs_info:git:*' formats "(%b%u%c${unpushed_commits}${untracked_files})%m "
        vcs_info
    fi
}

# Distribution icon function
distro_icon() {
    if [[ "$(get_os_type)" == "macos" ]]; then
        echo ""
    elif [ ! -f /etc/os-release ]; then
        echo ""
    elif grep -q 'ID=debian' /etc/os-release; then
        echo "꩜"
    elif grep -q 'ID=arch' /etc/os-release; then
        echo "⮝"
    elif grep -q 'ID=ubuntu' /etc/os-release; then
        echo "🟠"
    else
        echo ""
    fi
}

docker_indicator() {
    if [ -f /.dockerenv ]; then
        echo " 🐋"
    fi
}

hostname_indicator() {
    if is_ssh; then
        echo "%m:"
    fi
}

# Enable prompt substitution
setopt prompt_subst

# Set the prompt
PROMPT='${prompt_error}${prompt_time}$(hostname_indicator)%~ $(distro_icon)$(docker_indicator) ${vcs_info_msg_0_}% ➜ '
