#!/usr/bin/env bash
# self-compact — let a long-running session compact its own context on purpose.
#
#   self-compact.sh check         measure this session's context against the threshold
#   self-compact.sh fire [file]   arm a /compact that runs once the current turn ends
#   self-compact.sh hook          Stop hook: types the keys after the turn has ended
#
# The model calls `check` from the /self-compact skill. Under the threshold it
# is a one-line no-op, so the skill is safe to invoke at every seam. Over it,
# the model writes a structured state file and calls `fire`, which arms a
# marker; the Stop hook sees the marker when the turn ends and drives
# `/compact <instructions>` into the session's own tmux pane, waits for the
# compaction to land in the transcript, then types a resume prompt pointing at
# the state file. Same technique as smart-start-switch.sh.
#
# Context is measured from the transcript: the last main-loop assistant
# message's usage block (input + cache read + cache creation) is the size of
# the context that produced it. A compact_boundary after it means the size is
# unknown-but-small, so it counts as zero.
#
#   SELF_COMPACT_THRESHOLD  tokens; default 150000
#   SELF_COMPACT_DELAY      seconds between the Stop hook and the keys; default 1
#   SELF_COMPACT_TIMEOUT    seconds to wait for the compaction; default 300
#   SELF_COMPACT_AUTO=1     the Stop hook also blocks the stop when over the
#                           threshold and tells the model to run /self-compact
set -eu

threshold=${SELF_COMPACT_THRESHOLD:-150000}

die() {
    echo "self-compact: $*" >&2
    exit 1
}

# The ##*/ keeps a stray slash from escaping the temp dir; the %/ drops the
# trailing slash macOS puts on TMPDIR.
state_dir() {
    local tmp=${TMPDIR:-/tmp}
    printf '%s/self-compact-%s' "${tmp%/}" "${1##*/}"
}

transcript_for() {
    find "$HOME/.claude/projects" -mindepth 2 -maxdepth 2 -name "$1.jsonl" 2>/dev/null | head -n 1
}

# Last main-loop context size seen in a stream of transcript lines, or nothing.
usage_filter() {
    jq -r '
        select(
            (.type == "assistant" and .isSidechain != true and (.message.usage // null) != null)
            or (.type == "system" and .subtype == "compact_boundary")
        )
        | if .type == "system" then 0
          else .message.usage
               | (.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0)
          end' 2>/dev/null | tail -n 1
}

context_tokens() {
    local n
    # The answer is near the end of what can be a very large file.
    n=$(tail -n 400 "$1" | usage_filter)
    [ -n "$n" ] || n=$(usage_filter < "$1")
    [ -n "$n" ] || n=$(( $(wc -c < "$1") / 4 ))
    echo "$n"
}

# send-keys to a missing pane fails, but display-message silently retargets
# the current pane, so list the panes rather than probing the target.
pane_live() {
    [ -n "${TMUX_PANE:-}" ] || return 1
    tmux list-panes -a -F '#{pane_id}' 2>/dev/null | grep -qxF "$TMUX_PANE"
}

hook_registered() {
    jq -e '[.hooks.Stop[]?.hooks[]?.command // "" | select(contains("self-compact"))] | length > 0' \
        "$HOME/.claude/settings.json" >/dev/null 2>&1
}

boundary_count() {
    grep -c '"subtype":"compact_boundary"' "$1" 2>/dev/null || true
}

compact_instructions() {
    printf '%s' "Self-compact: the final assistant turn wrote a state file to $1. Reproduce that file's content verbatim in the summary: the task, the per-ticket state table, the user's rulings, the in-flight agents with their names and tickets, and the next step. Beyond that keep only decisions and open questions; drop tool output, gate logs and agent prose."
}

resume_prompt() {
    printf '%s' "Context was compacted by /self-compact. Run: cat $1 -- that file is the authoritative state; continue from its Next step."
}

type_line() {
    tmux send-keys -t "$1" -l -- "$2"
    sleep 0.3
    tmux send-keys -t "$1" Enter
}

# Runs detached from the hook's stdio so Claude Code isn't left waiting on the
# pipe. Keys sent mid-turn queue instead of submitting, so the delay lets the
# turn finish halting first.
drive_compaction() {
    local pane=$1 transcript=$2 file=$3 before deadline
    sleep "${SELF_COMPACT_DELAY:-1}"
    before=$(boundary_count "$transcript")
    type_line "$pane" "/compact $(compact_instructions "$file")"
    deadline=$((SECONDS + ${SELF_COMPACT_TIMEOUT:-300}))
    until [ "$(boundary_count "$transcript")" -gt "$before" ] || [ "$SECONDS" -ge "$deadline" ]; do
        sleep 2
    done
    sleep 1
    type_line "$pane" "$(resume_prompt "$file")"
}

cmd_check() {
    local sid transcript tokens dir
    sid=${CLAUDE_CODE_SESSION_ID:-}
    [ -n "$sid" ] || die "CLAUDE_CODE_SESSION_ID is not set; run this from inside a Claude Code session"
    transcript=$(transcript_for "$sid")
    [ -n "$transcript" ] || die "no transcript for session $sid under ~/.claude/projects"
    tokens=$(context_tokens "$transcript")
    dir=$(state_dir "$sid")
    if [ "$tokens" -lt "$threshold" ]; then
        echo "self-compact: context is $tokens tokens, under the $threshold threshold; nothing to do."
    elif ! pane_live; then
        echo "self-compact: context is $tokens tokens, over the $threshold threshold, but this session is not in tmux so /compact cannot be driven. Tell the user and stop."
    elif ! hook_registered; then
        echo "self-compact: context is $tokens tokens, over the $threshold threshold, but the self-compact Stop hook is not registered in ~/.claude/settings.json. Tell the user and stop."
    else
        echo "self-compact: context is $tokens tokens, over the $threshold threshold. Write the state file to $dir/state.md, then run: self-compact.sh fire"
    fi
}

cmd_fire() {
    local sid dir file
    sid=${CLAUDE_CODE_SESSION_ID:-}
    [ -n "$sid" ] || die "CLAUDE_CODE_SESSION_ID is not set; run this from inside a Claude Code session"
    dir=$(state_dir "$sid")
    file=${1:-$dir/state.md}
    [ -s "$file" ] || die "state file $file is missing or empty; write it before firing"
    pane_live || die "not in tmux (or the pane is gone); nothing armed. Run /compact yourself and preserve $file."
    hook_registered || die "the self-compact Stop hook is not registered in ~/.claude/settings.json; nothing armed"
    mkdir -p "$dir"
    printf '%s\n' "$file" > "$dir/armed"
    echo "self-compact: armed. /compact runs when this turn ends and you will be resumed with a pointer at $file. End the turn now with a one-line note and do nothing else."
}

cmd_hook() {
    local input sid transcript active dir file tokens
    input=$(cat)
    sid=$(printf '%s' "$input" | jq -r '.session_id // ""')
    transcript=$(printf '%s' "$input" | jq -r '.transcript_path // ""')
    active=$(printf '%s' "$input" | jq -r '.stop_hook_active // false')
    [ -n "$sid" ] || exit 0
    dir=$(state_dir "$sid")

    if [ -f "$dir/armed" ]; then
        file=$(cat "$dir/armed")
        mv "$dir/armed" "$dir/fired"
        pane_live || exit 0
        drive_compaction "$TMUX_PANE" "$transcript" "$file" >/dev/null 2>&1 &
        exit 0
    fi

    [ "${SELF_COMPACT_AUTO:-}" = 1 ] || exit 0
    # Already continuing because of a Stop hook: never block twice in a row.
    [ "$active" != true ] || exit 0
    [ -f "$transcript" ] || exit 0
    pane_live || exit 0
    tokens=$(context_tokens "$transcript")
    [ "$tokens" -ge "$threshold" ] || exit 0
    jq -cn --arg reason "Context is $tokens tokens, over the self-compact threshold of $threshold. Invoke the self-compact skill now." \
        '{decision: "block", reason: $reason}'
}

case "${1:-}" in
    check) cmd_check ;;
    fire) shift; cmd_fire "$@" ;;
    hook) cmd_hook ;;
    *)
        echo "usage: self-compact.sh check | fire [state-file] | hook" >&2
        exit 2
        ;;
esac
