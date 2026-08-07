#!/bin/sh
# Smart Start — switch models at the first main-loop file edit.
#
# Registered as a PostToolUse hook on Edit|Write. Inert unless
# SMART_START_THEN names the model to switch to; `smart-start` sets it.
#
# The expensive model does the reading and planning; the moment it makes its
# first real edit this halts the turn, drives /model over tmux, and tells it to
# continue — so the cheap model finishes the work with the expensive model's
# exploration already in context instead of re-deriving it.
#
# SMART_START_DELAY tunes the seconds spent waiting for the turn to halt.
set -eu

[ -n "${SMART_START_THEN:-}" ] || exit 0
[ -n "${TMUX_PANE:-}" ] || exit 0

# A stale pane would mean halting the turn with no way to restart it, so make
# sure the keystrokes have somewhere to land before committing to the switch.
# (send-keys to a missing pane fails, but display-message silently retargets
# the current pane, so list the panes rather than probing the target.)
tmux list-panes -a -F '#{pane_id}' 2>/dev/null | grep -qxF "$TMUX_PANE" || exit 0

input=$(cat)

# Subagent edits aren't the main loop handing off its own reasoning, and
# subagents may already be running a cheaper tier.
[ -z "$(printf '%s' "$input" | jq -r '.agent_id // ""')" ] || exit 0

session_id=$(printf '%s' "$input" | jq -r '.session_id // ""')
[ -n "$session_id" ] || exit 0

# One switch per session, latched atomically — a failed mkdir means either
# already switched or nowhere to write, and both should leave the model alone.
# /clear mints a new session id, which re-arms: after a clear you're exploring
# from scratch again. The ##*/ keeps a stray slash from escaping the temp dir.
mkdir "${TMPDIR:-/tmp}/smart-start-${session_id##*/}" 2>/dev/null || exit 0

# Keys sent to the pane mid-turn queue instead of submitting, so wait for the
# halt below to land them on an idle prompt. Detached from this hook's stdio so
# Claude Code isn't left waiting on the pipe.
(
    sleep "${SMART_START_DELAY:-1}"
    tmux send-keys -t "$TMUX_PANE" "/model $SMART_START_THEN" Enter
    sleep 0.5
    tmux send-keys -t "$TMUX_PANE" Enter
    tmux send-keys -t "$TMUX_PANE" continue Enter
) >/dev/null 2>&1 &

jq -cn --arg model "$SMART_START_THEN" \
    '{continue: false, stopReason: "Smart Start: switching to \($model), then continuing automatically."}'
