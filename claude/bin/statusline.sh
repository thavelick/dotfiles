#!/bin/sh
# Claude Code status line: directory, model, context/token usage, session cost, active time.
# Receives session JSON on stdin. See https://code.claude.com/docs/en/statusline

input=$(cat)

field() { echo "$input" | jq -r "$1"; }

dir=$(basename "$(field '.workspace.current_dir')")
model=$(field '.model.display_name')
used=$(field '.context_window.used_percentage // 0')
tin=$(field '.context_window.total_input_tokens // 0')
tout=$(field '.context_window.total_output_tokens // 0')
size=$(field '.context_window.context_window_size // 0')
cost=$(field '.cost.total_cost_usd // empty')
transcript=$(field '.transcript_path // empty')

# 41990 -> 42k, 1000000 -> 1m, 1240000 -> 1.2m, 320 -> 320
human() {
  awk -v n="$1" 'BEGIN {
    n += 0
    if (n >= 1000000) { s = sprintf("%.1f", n / 1000000); sub(/\.0$/, "", s); print s "m" }
    else if (n >= 1000) { printf "%.0fk\n", n / 1000 }
    else { printf "%d\n", n }
  }'
}

# Time actually spent working, in ms: the sum of gaps between transcript entries,
# with each gap capped at IDLE_CUTOFF so an afk stretch counts as a pause, not work.
IDLE_CUTOFF=900
active_ms() {
  [ -f "$1" ] || return
  jq -r 'select(.timestamp) | .timestamp | sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601' "$1" 2>/dev/null |
    sort -n |
    awk -v cut="$IDLE_CUTOFF" '
      NR > 1 { d = $1 - prev; total += (d > cut ? cut : d) }
      { prev = $1 }
      END { printf "%d\n", total * 1000 }'
}

# Milliseconds -> minute resolution: 720000 -> 12m, 6420000 -> 1h47m
human_time() {
  awk -v ms="$1" 'BEGIN {
    m = int((ms + 0) / 60000)
    if (m >= 60) printf "%dh%02dm\n", m / 60, m % 60
    else printf "%dm\n", m
  }'
}

# Green under 50% of the context window, yellow to 80%, red beyond.
color=$(awk -v u="$used" 'BEGIN {
  u += 0
  if (u >= 80) print "31"; else if (u >= 50) print "33"; else print "32"
}')
pct=$(awk -v u="$used" 'BEGIN { printf "%.0f", u + 0 }')

printf '\033[2m%s\033[0m \033[36m%s\033[0m \033[1;%sm[ctx %s%% | %s/%s tok]\033[0m' \
  "$dir" "$model" "$color" "$pct" "$(human $((tin + tout)))" "$(human "$size")"

if [ -n "$cost" ]; then
  printf ' \033[2m$%.2f\033[0m' "$cost"
fi

active=$(active_ms "$transcript")
if [ -n "$active" ]; then
  printf '  \033[2m⏱ %s\033[0m' "$(human_time "$active")"
fi
