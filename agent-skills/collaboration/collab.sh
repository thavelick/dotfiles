#!/bin/bash
# Shared editor for a Claude session: one collaboration doc, plus any file the
# agent wants to put in front of the user.
#
# The doc lives in the session's scratchpad, so resuming a session finds the
# same file. The editor pane is keyed by tmux window rather than by session, so
# /clear — which mints a new session and therefore a new doc — still lands in the
# editor already open. Everything is idempotent: nothing is ever opened twice.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: collab.sh [--focus] [--dir DIR] [--template FILE]
       collab.sh open [--focus] FILE [LINE [COL]]

  (no args)  open this session's collaboration doc, spawning the pane if needed
  open       show FILE in the collaboration editor, optionally at LINE and COL

  --focus    make the editor pane active (default: leave focus where it is)
  --dir DIR  scratchpad directory to use, if auto-detection fails
  --template FILE
             seed a brand-new doc with FILE instead of the default header;
             ignored when the doc already exists, so re-runs never clobber it
  --edit F   internal: exec the editor on F (used as the pane's command)
  --sock S   internal: nvim --listen address for the pane started by --edit

There is exactly one collaboration doc per session; it is not named or chosen.
USAGE
}

editor="${EDITOR:-vim}"

# --edit is how the spawned pane re-enters this script, so that the editor's
# +cmd arguments never have to survive a trip through tmux's shell quoting.
if [ "${1:-}" = "--edit" ]; then
  doc="${2:?--edit needs a file}"
  listen=()
  [ "${3:-}" = "--sock" ] && [ -n "${4:-}" ] && listen=(--listen "$4")
  # -n: no swapfile. Panes get killed rather than quit, and a stale swapfile
  # would greet the next open with a recovery prompt on a throwaway scratch doc.
  # autoread + a repeating checktime means notes written by Claude show up in
  # the pane on their own. An unsaved buffer still prompts rather than being
  # clobbered.
  exec "$editor" -n "${listen[@]}" \
    -c 'set autoread' \
    -c 'autocmd CursorHold,CursorHoldI,FocusGained,BufEnter * silent! checktime' \
    -c 'call timer_start(1000, {-> execute("silent! checktime")}, {"repeat": -1})' \
    "$doc"
fi

subcommand=doc
if [ "${1:-}" = "open" ]; then
  subcommand=open
  shift
fi

focus=false
dir=""
template=""
args=()

while [ $# -gt 0 ]; do
  case "$1" in
    --focus) focus=true; shift ;;
    --dir) dir="${2:?--dir needs a path}"; shift 2 ;;
    --template) template="${2:?--template needs a path}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
    *) args+=("$1"); shift ;;
  esac
done

if [ -n "$template" ]; then
  if [ "$subcommand" != doc ]; then
    echo "--template applies to the collaboration doc, not to open" >&2
    usage >&2
    exit 2
  fi
  if [ ! -f "$template" ]; then
    echo "no such template: $template" >&2
    exit 1
  fi
fi

if [ "$subcommand" = doc ] && [ ${#args[@]} -gt 0 ]; then
  echo "unexpected argument: ${args[0]}" >&2
  usage >&2
  exit 2
fi

# --- doc location -----------------------------------------------------------
# The scratchpad path embeds the session id, which is what ties the doc to the
# session. Glob for it rather than rebuilding the project slug by hand.
if [ -z "$dir" ]; then
  session="${CLAUDE_CODE_SESSION_ID:-}"
  if [ -z "$session" ]; then
    echo "CLAUDE_CODE_SESSION_ID is unset and --dir was not given." >&2
    exit 1
  fi
  for candidate in /tmp/claude-*/*/"$session"/scratchpad; do
    if [ -d "$candidate" ]; then
      dir="$candidate"
      break
    fi
  done
  # No scratchpad on disk yet (or a layout this glob doesn't know): fall back to
  # a session-keyed directory of our own rather than guessing wrong.
  if [ -z "$dir" ]; then
    dir="${TMPDIR:-/tmp}/claude-collab/$session"
  fi
fi

mkdir -p "$dir"
doc="$dir/collaboration.md"

created=false
if [ ! -e "$doc" ]; then
  created=true
  # A template stands in for the header entirely: a doc that titles itself does
  # not need the generic blurb explaining what a collaboration doc is.
  if [ -n "$template" ]; then
    cat "$template" > "$doc"
  else
    cat > "$doc" <<'HEADER'
# Collaboration doc

Shared scratch for this Claude session. Claude writes its notes here; edit or
annotate in place and Claude will read your changes back.

HEADER
  fi
fi

# --- editor plumbing --------------------------------------------------------
# --remote only exists on nvim; plain vim gets a pane with the doc and nothing
# else, since there is no way to hand it further files from outside.
remote_capable=false
case "$(basename "$editor")" in nvim) remote_capable=true ;; esac

sock=""
if [ -n "${TMUX:-}" ]; then
  # Keyed by window rather than by session: a Claude session that ends at /clear
  # takes its doc with it, but the window — and the editor in it — stays.
  window=$(tmux display-message -p -t "${TMUX_PANE:-}" '#{window_id}')
  sockdir="${TMPDIR:-/tmp}/claude-collab"
  sock="$sockdir/nvim-${window//[^a-zA-Z0-9]/}.sock"
  mkdir -p "$sockdir"
fi

# Every remote call goes through here. An empty --server argument makes nvim
# start a real editor on this shell's pty and hang, so the socket is checked
# rather than trusted.
remote() {
  [ -S "$sock" ] || return 1
  nvim --server "$sock" "$@" </dev/null
}

editor_live() {
  [ "$remote_capable" = true ] && remote --remote-expr '1' >/dev/null 2>&1
}

# A pane started by this script carries the doc path and its socket in the start
# command, so the tmux server itself is the record of what is open — no state
# file to go stale when a pane is killed.
pane_matching() {
  tmux list-panes -a -F '#{pane_id} #{pane_start_command}' 2>/dev/null |
    awk -v needle="$1" 'index($0, needle) { print $1; exit }'
}

focus_pane() {
  if [ "$focus" = true ] && [ -n "$1" ]; then
    tmux select-window -t "$1"
    tmux select-pane -t "$1"
  fi
}

spawn_pane() {
  local self split_args cmd
  self=$(cd "$(dirname "$0")" && pwd)/$(basename "$0")
  split_args=(-h -P -F '#{pane_id}' -t "${TMUX_PANE:-}" -c "$dir")
  [ "$focus" = true ] || split_args+=(-d)
  if [ "$remote_capable" = true ]; then
    cmd=$(printf '%q --edit %q --sock %q' "$self" "$doc" "$sock")
  else
    cmd=$(printf '%q --edit %q' "$self" "$doc")
  fi
  tmux split-window "${split_args[@]}" "$cmd"
}

# nvim binds its socket a moment after the pane starts; without this, an `open`
# that spawned the pane would race the editor and fall back to a second pane.
wait_for_editor() {
  local tries=30
  while [ "$tries" -gt 0 ]; do
    editor_live && return 0
    sleep 0.1
    tries=$((tries - 1))
  done
  return 1
}

# --- doc: ensure the editor is up and showing the collaboration doc ----------
if [ "$subcommand" = doc ]; then
  if [ -z "${TMUX:-}" ]; then
    printf 'status: no-tmux\ndoc: %s\ncreated: %s\nopen-with: %s %s\n' \
      "$doc" "$created" "$editor" "$doc"
    exit 0
  fi

  if editor_live; then
    pane=$(pane_matching "--sock $sock")
    current=$(remote --remote-expr 'expand("%:p")' 2>/dev/null || true)
    if [ "$current" = "$doc" ]; then
      status=reused
    else
      remote --remote-tab "$doc" >/dev/null
      status=attached
    fi
    focus_pane "$pane"
    printf 'status: %s\ndoc: %s\ncreated: %s\npane: %s\n' "$status" "$doc" "$created" "$pane"
    exit 0
  fi

  # Socket may have outlived its nvim. Clear it so --listen can bind again.
  [ -n "$sock" ] && [ -e "$sock" ] &&
    find "$(dirname "$sock")" -maxdepth 1 -name "$(basename "$sock")" -delete

  # A plain-vim pane has no socket, so fall back to matching the doc itself.
  if pane=$(pane_matching "--edit $doc") && [ -n "$pane" ]; then
    focus_pane "$pane"
    printf 'status: reused\ndoc: %s\ncreated: %s\npane: %s\n' "$doc" "$created" "$pane"
    exit 0
  fi

  pane=$(spawn_pane)
  printf 'status: opened\ndoc: %s\ncreated: %s\npane: %s\n' "$doc" "$created" "$pane"
  exit 0
fi

# --- open: show an arbitrary file in the collaboration editor ----------------
file="${args[0]:-}"
line="${args[1]:-}"
col="${args[2]:-1}"

if [ -z "$file" ]; then
  echo "open needs a FILE" >&2
  usage >&2
  exit 2
fi
if [ ! -e "$file" ]; then
  echo "no such file: $file" >&2
  exit 1
fi
file=$(cd "$(dirname "$file")" && pwd)/$(basename "$file")

if [ -z "${TMUX:-}" ] || [ "$remote_capable" = false ]; then
  printf 'status: unsupported\nfile: %s\nopen-with: %s %s\n' "$file" "$editor" "$file"
  exit 0
fi

if ! editor_live; then
  [ -e "$sock" ] &&
    find "$(dirname "$sock")" -maxdepth 1 -name "$(basename "$sock")" -delete
  spawn_pane >/dev/null
  wait_for_editor || { echo "editor did not come up on $sock" >&2; exit 1; }
fi

# :tab drop, which is what --remote-tab runs, reuses a tab already showing the
# file. Counting tabs across the call is how we tell the user which happened.
before=$(remote --remote-expr 'tabpagenr("$")')
remote --remote-tab "$file" >/dev/null
after=$(remote --remote-expr 'tabpagenr("$")')

status=switched-tab
[ "$after" -gt "$before" ] && status=opened-tab

if [ -n "$line" ]; then
  remote --remote-expr "cursor($line,$col)" >/dev/null
fi

pane=$(pane_matching "--sock $sock")
focus_pane "$pane"
printf 'status: %s\nfile: %s\ntabs: %s\npane: %s\n' "$status" "$file" "$after" "$pane"
[ -n "$line" ] && printf 'cursor: %s:%s\n' "$line" "$col"
exit 0
